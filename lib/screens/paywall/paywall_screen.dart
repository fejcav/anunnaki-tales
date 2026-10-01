import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/stars_background.dart';

// Por ahora solo avisa que Premium llega pronto. Las tarjetas de compra
// llegan en la iteración 8. Se cierra devolviendo `false` (no compró).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywallTitle)),
      body: StarsBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.paywallComingSoon, style: AppText.title, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
