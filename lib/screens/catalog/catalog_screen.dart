import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/stars_background.dart';

// Pantalla vacía: se completa en su iteración (ver docs/plan-migracion.md).
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).catalogTitle)),
      body: const StarsBackground(child: SizedBox.expand()),
    );
  }
}
