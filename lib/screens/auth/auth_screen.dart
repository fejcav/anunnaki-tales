import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

// Pantalla vacía: se completa en la iteración 2. Es la única sin flecha atrás.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context).authTitle),
      ),
      body: const SizedBox.expand(),
    );
  }
}
