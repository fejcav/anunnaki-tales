import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

// Pantalla vacía: se completa en su iteración (ver docs/plan-migracion.md).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).paywallTitle)),
      body: const SizedBox.expand(),
    );
  }
}
