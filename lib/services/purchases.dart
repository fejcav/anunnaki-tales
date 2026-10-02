import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config.dart';

// Los dos planes del Paywall, con el precio tal como lo devuelve la tienda.
enum PremiumPeriod { monthly, annual }

class PremiumPlan {
  const PremiumPlan({required this.period, required this.price});

  final PremiumPeriod period;
  final String price; // ya formateado por la tienda, con su moneda
}

// Cómo terminó una compra.
enum BuyResult { premium, cancelled, failed }

// ÚNICA clase que toca purchases_flutter (RevenueCat). No decide nada: dice si
// el usuario tiene el entitlement `premium`, trae los planes, compra y
// restaura. Si la tienda falla, lo anota con debugPrint y responde "sin
// Premium" o "falló"; nunca deja pasar la excepción.
class PurchasesService {
  static const _entitlement = 'premium';

  bool _configured = false;

  // Los paquetes que devolvió la tienda la última vez, para comprarlos.
  final Map<PremiumPeriod, Package> _packages = {};

  // Se llama una vez al arrancar. En iOS todavía no hay clave (iteración 13):
  // ahí no se configura y todos son gratis.
  Future<void> configure() async {
    if (!Platform.isAndroid) return;
    try {
      await Purchases.configure(PurchasesConfiguration(AppConfig.revenueCatAndroidKey));
      _configured = true;
    } catch (e) {
      debugPrint('RevenueCat: no se pudo configurar: $e');
    }
  }

  // Avisa cada vez que RevenueCat recibe datos nuevos del usuario (compra,
  // renovación, vencimiento) con si tiene Premium o no.
  void listen(void Function(bool isPremium) onChange) {
    if (!_configured) return;
    Purchases.addCustomerInfoUpdateListener((info) => onChange(_hasPremium(info)));
  }

  // Asocia las compras al usuario de Supabase, así el Premium lo sigue entre
  // teléfonos. Devuelve si tiene Premium.
  Future<bool> logIn(String userId) async {
    if (!_configured) return false;
    try {
      final result = await Purchases.logIn(userId);
      return _hasPremium(result.customerInfo);
    } catch (e) {
      debugPrint('RevenueCat: falló logIn: $e');
      return false;
    }
  }

  // Al cerrar sesión o eliminar la cuenta: RevenueCat pasa a un usuario anónimo.
  Future<void> logOut() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      // Falla si el usuario ya era anónimo: no importa.
      debugPrint('RevenueCat: falló logOut: $e');
    }
  }

  // Lee de nuevo si el usuario tiene Premium.
  Future<bool> isPremium() async {
    if (!_configured) return false;
    try {
      return _hasPremium(await Purchases.getCustomerInfo());
    } catch (e) {
      debugPrint('RevenueCat: falló getCustomerInfo: $e');
      return false;
    }
  }

  // Los planes del offering actual, el anual primero. Lista vacía si la
  // tienda no responde.
  Future<List<PremiumPlan>> loadPlans() async {
    if (!_configured) return const [];
    try {
      final offering = (await Purchases.getOfferings()).current;
      _packages.clear();
      if (offering?.annual != null) _packages[PremiumPeriod.annual] = offering!.annual!;
      if (offering?.monthly != null) _packages[PremiumPeriod.monthly] = offering!.monthly!;
      return [
        for (final entry in _packages.entries)
          PremiumPlan(period: entry.key, price: entry.value.storeProduct.priceString),
      ];
    } catch (e) {
      debugPrint('RevenueCat: falló getOfferings: $e');
      return const [];
    }
  }

  // Compra un plan de los que trajo [loadPlans]. Lo que devuelve la compra
  // cambió entre versiones del paquete: por eso, después, siempre se vuelve a
  // leer el usuario y se mira el entitlement.
  Future<BuyResult> buy(PremiumPeriod period) async {
    final package = _packages[period];
    if (!_configured || package == null) return BuyResult.failed;
    try {
      await Purchases.purchase(PurchaseParams.package(package));
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) == PurchasesErrorCode.purchaseCancelledError) {
        return BuyResult.cancelled;
      }
      debugPrint('RevenueCat: falló la compra: $e');
      return BuyResult.failed;
    } catch (e) {
      debugPrint('RevenueCat: falló la compra: $e');
      return BuyResult.failed;
    }
    return await isPremium() ? BuyResult.premium : BuyResult.failed;
  }

  // Restaura compras anteriores de la cuenta de la tienda. Devuelve si quedó
  // Premium, o null si la tienda no respondió.
  Future<bool?> restore() async {
    if (!_configured) return null;
    try {
      await Purchases.restorePurchases();
      return _hasPremium(await Purchases.getCustomerInfo());
    } catch (e) {
      debugPrint('RevenueCat: falló restaurar: $e');
      return null;
    }
  }

  bool _hasPremium(CustomerInfo info) => info.entitlements.all[_entitlement]?.isActive ?? false;
}
