// Reglas de la compra única, como funciones puras: qué hacer con cada evento
// que manda la tienda (dar la compra por hecha, reconocerla o nada) y qué
// aventuras están abiertas. No tocan pantallas ni el paquete de compras:
// `services/purchases.dart` traduce lo que llega de la tienda a [PurchaseEvent]
// y aplica lo que se decide acá.

import '../config.dart';

// En qué estado llega una compra desde la tienda.
enum PurchaseEventStatus { pending, purchased, restored, error, canceled }

// Una compra tal como la manda la tienda, sin tipos del paquete.
class PurchaseEvent {
  const PurchaseEvent({
    required this.productId,
    required this.status,
    this.pendingCompletePurchase = false,
  });

  final String productId;
  final PurchaseEventStatus status;

  // La tienda espera que la app la reconozca (`completePurchase`).
  final bool pendingCompletePurchase;
}

// Lo que se decidió para un evento.
class PurchaseDecision {
  const PurchaseDecision({
    required this.purchased,
    required this.acknowledge,
    required this.pending,
  });

  // Cómo tiene que quedar la compra (igual que antes si no cambia nada).
  final bool purchased;

  // Hay que reconocer la compra en la tienda (si no, Google la reembolsa).
  final bool acknowledge;

  // La compra quedó pendiente (pago en efectivo, por ejemplo): se muestra
  // "Compra pendiente" hasta que la tienda la resuelva.
  final bool pending;
}

// Qué decide el Catálogo para cada aventura.
enum AdventureStatus { open, locked, comingSoon }

// Decide qué hacer con un evento. Solo `anunnaki_completo` comprado o
// restaurado da la compra por hecha; nada la deshace.
PurchaseDecision decidePurchase(bool purchased, PurchaseEvent event) {
  if (event.productId != AppConfig.fullUnlockProductId) {
    return PurchaseDecision(purchased: purchased, acknowledge: false, pending: false);
  }
  switch (event.status) {
    case PurchaseEventStatus.purchased:
    case PurchaseEventStatus.restored:
      return PurchaseDecision(
        purchased: true,
        acknowledge: event.status == PurchaseEventStatus.purchased || event.pendingCompletePurchase,
        pending: false,
      );
    case PurchaseEventStatus.pending:
      return PurchaseDecision(purchased: purchased, acknowledge: false, pending: true);
    case PurchaseEventStatus.error:
    case PurchaseEventStatus.canceled:
      return PurchaseDecision(purchased: purchased, acknowledge: false, pending: false);
  }
}

// "Restaurar compra" encontró el producto entre las compras pasadas.
bool restoreFound(List<PurchaseEvent> events) => events.any(
  (e) =>
      e.productId == AppConfig.fullUnlockProductId &&
      (e.status == PurchaseEventStatus.purchased || e.status == PurchaseEventStatus.restored),
);

// Una aventura sin historia es "Próximamente" (haya compra o no); con
// historia, está abierta si es gratis o si se hizo la compra.
AdventureStatus adventureStatus({
  required bool hasStory,
  required bool isFree,
  required bool purchased,
}) {
  if (!hasStory) return AdventureStatus.comingSoon;
  return isFree || purchased ? AdventureStatus.open : AdventureStatus.locked;
}
