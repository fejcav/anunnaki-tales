import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/purchases.dart';

// Estado compartido de la app. Por ahora solo si el usuario tiene Premium:
// las pantallas lo leen con context.watch<AppState>().isPremium.
class AppState extends ChangeNotifier {
  AppState({required this.auth, required this.purchases});

  final AuthService auth;
  final PurchasesService purchases;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  // Se llama una vez al arrancar. Cada vez que cambia el usuario de Supabase,
  // se avisa a RevenueCat (logIn o logOut) y se relee Premium. Además, se
  // escuchan los cambios que manda RevenueCat (compra, renovación, vencimiento).
  void start() {
    purchases.listen(setPremium);
    auth.userIdChanges.listen((userId) async {
      if (userId == null) {
        setPremium(false);
        await purchases.logOut();
      } else {
        setPremium(await purchases.logIn(userId));
      }
    });
  }

  // También se llama después de comprar o restaurar (Paywall y Perfil).
  void setPremium(bool value) {
    if (value == _isPremium) return;
    _isPremium = value;
    notifyListeners();
  }
}
