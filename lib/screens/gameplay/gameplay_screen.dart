import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/stars_background.dart';

// Pantalla vacía: se completa en su iteración (ver docs/plan-migracion.md).
class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).gameplayTitle)),
      body: const StarsBackground(child: SizedBox.expand()),
    );
  }
}
