import 'package:anunnakitales/config.dart';
import 'package:anunnakitales/logic/purchase_rules.dart';
import 'package:flutter_test/flutter_test.dart';

PurchaseEvent event(
  PurchaseEventStatus status, {
  String productId = AppConfig.fullUnlockProductId,
  bool pendingCompletePurchase = false,
}) => PurchaseEvent(
  productId: productId,
  status: status,
  pendingCompletePurchase: pendingCompletePurchase,
);

void main() {
  group('decidePurchase', () {
    test('comprado: queda la compra y se reconoce', () {
      final d = decidePurchase(
        false,
        event(PurchaseEventStatus.purchased, pendingCompletePurchase: true),
      );
      expect(d.purchased, isTrue);
      expect(d.acknowledge, isTrue);
      expect(d.pending, isFalse);
    });

    test('comprado sin pendingCompletePurchase: igual se reconoce', () {
      final d = decidePurchase(false, event(PurchaseEventStatus.purchased));
      expect(d.purchased, isTrue);
      expect(d.acknowledge, isTrue);
    });

    test('restaurado sin reconocer: queda la compra y se reconoce', () {
      final d = decidePurchase(
        false,
        event(PurchaseEventStatus.restored, pendingCompletePurchase: true),
      );
      expect(d.purchased, isTrue);
      expect(d.acknowledge, isTrue);
    });

    test('restaurado ya reconocido: queda la compra y no se reconoce otra vez', () {
      final d = decidePurchase(false, event(PurchaseEventStatus.restored));
      expect(d.purchased, isTrue);
      expect(d.acknowledge, isFalse);
    });

    test('pendiente: sin compra todavía y estado pendiente', () {
      final d = decidePurchase(false, event(PurchaseEventStatus.pending));
      expect(d.purchased, isFalse);
      expect(d.acknowledge, isFalse);
      expect(d.pending, isTrue);
    });

    for (final status in [PurchaseEventStatus.error, PurchaseEventStatus.canceled]) {
      test('${status.name}: sin cambio', () {
        final d = decidePurchase(false, event(status));
        expect(d.purchased, isFalse);
        expect(d.acknowledge, isFalse);
        expect(d.pending, isFalse);
      });

      test('${status.name} con la compra hecha: no la deshace', () {
        expect(decidePurchase(true, event(status)).purchased, isTrue);
      });
    }

    test('otro producto: sin cambio', () {
      final d = decidePurchase(
        false,
        event(
          PurchaseEventStatus.purchased,
          productId: 'otro_producto',
          pendingCompletePurchase: true,
        ),
      );
      expect(d.purchased, isFalse);
      expect(d.acknowledge, isFalse);
      expect(d.pending, isFalse);
    });
  });

  group('restoreFound', () {
    test('sin compras: no encuentra nada', () {
      expect(restoreFound([]), isFalse);
    });

    test('con el producto restaurado: lo encuentra', () {
      expect(restoreFound([event(PurchaseEventStatus.restored)]), isTrue);
    });

    test('solo otros productos o una compra pendiente: no encuentra nada', () {
      expect(
        restoreFound([
          event(PurchaseEventStatus.restored, productId: 'otro_producto'),
          event(PurchaseEventStatus.pending),
        ]),
        isFalse,
      );
    });
  });

  group('adventureStatus', () {
    test('gratis con historia: abierta, con o sin compra', () {
      expect(adventureStatus(hasStory: true, isFree: true, purchased: false), AdventureStatus.open);
      expect(adventureStatus(hasStory: true, isFree: true, purchased: true), AdventureStatus.open);
    });

    test('no gratis con historia: candado sin compra, abierta con compra', () {
      expect(
        adventureStatus(hasStory: true, isFree: false, purchased: false),
        AdventureStatus.locked,
      );
      expect(adventureStatus(hasStory: true, isFree: false, purchased: true), AdventureStatus.open);
    });

    test('sin historia: "Próximamente" aunque haya compra', () {
      for (final isFree in [true, false]) {
        for (final purchased in [true, false]) {
          expect(
            adventureStatus(hasStory: false, isFree: isFree, purchased: purchased),
            AdventureStatus.comingSoon,
          );
        }
      }
    });
  });
}
