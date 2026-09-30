import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/stars_background.dart';

// Por ahora solo el título; los botones llegan en la iteración 3.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: StarsBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.homeTitle, style: AppText.logo, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l10n.homeSubtitle, style: AppText.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
