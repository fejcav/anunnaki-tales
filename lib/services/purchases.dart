import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../config.dart';
import '../logic/purchase_rules.dart';
import '../state/app_state.dart';

// Cómo terminó "Restaurar compra".
enum RestoreResult { found, notFound, failed }

// Si la tienda no contesta la consulta de compras pasadas, se da por vacía.
const _restoreTimeout = Duration(seconds: 15);

// ÚNICA clase que toca `in_app_purchase`. Sabe si la tienda está disponible,
// lee el precio de `anunnaki_completo` (una vez por arranque), abre la compra,
// reconoce lo comprado y restaura compras pasadas (al pedirlo y, en silencio,
// al arrancar). Qué hacer con cada evento lo decide `logic/purchase_rules.dart`;
// acá solo se aplica (la compra queda guardada en AppState). Un error de la tienda se anota con `debugPrint` y deja
// todo como estaba.
class PurchasesService extends ChangeNotifier {
  PurchasesService({required this.appState});

  final AppState appState;

  final InAppPurchase _store = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // La lectura de disponibilidad y precio del arranque.
  Future<void>? _loading;

  bool _available = false;
  bool get isAvailable => _available;

  // El producto tal como lo devolvió la tienda, con su precio ya formateado.
  ProductDetails? _product;
  String? get price => _product?.price;

  // Hay una compra esperando que la tienda confirme el pago.
  bool _pending = false;
  bool get pending => _pending;

  // La consulta de compras pasadas en curso: lo que trae llega por el stream.
  Completer<List<PurchaseEvent>>? _restoring;

  // Se llama una vez al arrancar: escucha las compras desde ya (una compra
  // pendiente puede llegar en cualquier momento) y lee disponibilidad y precio
  // sin frenar el arranque. Si la compra no está guardada (por ejemplo,
  // después de reinstalar), consulta en silencio las compras pasadas: si
  // aparece, queda hecha igual que con "Restaurar compra"; si no aparece o la
  // tienda no contesta, sigue todo como estaba.
  void start() {
    _subscription = _store.purchaseStream.listen(
      _onPurchases,
      onError: (Object error) => debugPrint('Compras: error en el stream: $error'),
    );
    _loading = _loadProduct();
    // Solo en Android. En iOS NO se consulta la tienda al arrancar, a
    // propósito: restaurar puede pedir la contraseña de Apple sin que el
    // usuario haya tocado nada. Ahí la compra se recupera solo con el botón
    // "Restaurar compra" (Ajustes o Paywall).
    if (!appState.purchased && defaultTargetPlatform == TargetPlatform.android) {
      unawaited(restore());
    }
  }

  Future<void> _loadProduct() async {
    try {
      _available = await _store.isAvailable();
      if (_available) {
        final response = await _store.queryProductDetails({AppConfig.fullUnlockProductId});
        if (response.error != null) {
          debugPrint('Compras: no se pudo leer el producto: ${response.error}');
        }
        if (response.notFoundIDs.isNotEmpty) {
          debugPrint('Compras: la tienda no conoce ${response.notFoundIDs}');
        }
        for (final product in response.productDetails) {
          if (product.id == AppConfig.fullUnlockProductId) _product = product;
        }
      }
    } catch (error) {
      debugPrint('Compras: la tienda no está disponible: $error');
      _available = false;
    }
    notifyListeners();
  }

  // Abre el diálogo de compra de la tienda. Lo que pase después llega por el
  // stream; cancelar no cambia nada.
  Future<void> buy() async {
    await _loading;
    final product = _product;
    if (!_available || product == null) return;
    try {
      await _store.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } catch (error) {
      debugPrint('Compras: no se pudo abrir la compra: $error');
    }
  }

  // Consulta las compras pasadas. Si aparece la compra, la da por hecha; si
  // no, no toca nada (la compra nunca se deshace sola).
  Future<RestoreResult> restore() async {
    await _loading;
    if (!_available) return RestoreResult.failed;
    final running = _restoring;
    final restoring = running ?? Completer<List<PurchaseEvent>>();
    if (running == null) {
      _restoring = restoring;
      try {
        await _store.restorePurchases();
      } catch (error) {
        debugPrint('Compras: no se pudo restaurar: $error');
        _restoring = null;
        return RestoreResult.failed;
      }
    }
    final events = await restoring.future.timeout(
      _restoreTimeout,
      onTimeout: () {
        if (identical(_restoring, restoring)) _restoring = null;
        return <PurchaseEvent>[];
      },
    );
    return restoreFound(events) ? RestoreResult.found : RestoreResult.notFound;
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    final events = <PurchaseEvent>[];
    bool? pending;

    for (final details in purchases) {
      final event = _toEvent(details);
      events.add(event);
      if (event.status == PurchaseEventStatus.error) {
        debugPrint('Compras: la compra falló: ${details.error}');
      } else if (event.status == PurchaseEventStatus.canceled) {
        debugPrint('Compras: compra cancelada');
      }

      final decision = decidePurchase(appState.purchased, event);
      if (event.productId == AppConfig.fullUnlockProductId) pending = decision.pending;
      if (decision.purchased && !appState.purchased) await appState.setPurchased();
      if (decision.acknowledge) {
        try {
          await _store.completePurchase(details);
        } catch (error) {
          debugPrint('Compras: no se pudo reconocer la compra: $error');
        }
      }
    }

    if (pending != null) _pending = pending;
    notifyListeners();

    // En Android, lo que trae "restaurar" llega en una sola tanda, toda como
    // restaurada (vacía si no hay compras).
    final restoring = _restoring;
    if (restoring != null && purchases.every((d) => d.status == PurchaseStatus.restored)) {
      _restoring = null;
      restoring.complete(events);
    }
  }

  // Traduce la compra de la tienda a los datos que usan las reglas. En Android
  // una compra restaurada puede estar todavía pendiente de pago: ahí se mira
  // el estado real en Google Play.
  PurchaseEvent _toEvent(PurchaseDetails details) {
    var status = switch (details.status) {
      PurchaseStatus.pending => PurchaseEventStatus.pending,
      PurchaseStatus.purchased => PurchaseEventStatus.purchased,
      PurchaseStatus.restored => PurchaseEventStatus.restored,
      PurchaseStatus.error => PurchaseEventStatus.error,
      PurchaseStatus.canceled => PurchaseEventStatus.canceled,
    };
    if (details is GooglePlayPurchaseDetails &&
        details.billingClientPurchase.purchaseState == PurchaseStateWrapper.pending) {
      status = PurchaseEventStatus.pending;
    }
    return PurchaseEvent(
      productId: details.productID,
      status: status,
      pendingCompletePurchase: details.pendingCompletePurchase,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
