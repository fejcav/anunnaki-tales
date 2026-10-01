import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/stars_background.dart';

// Inicio: título, "Comenzar aventura" y el ícono de perfil arriba a la derecha.
// "Continuar partida" llega en la iteración 6.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: StarsBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.person_outline, color: AppColors.gold),
                  tooltip: l10n.profileTitle,
                  onPressed: () => Navigator.of(context).pushNamed(Routes.profile),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.homeTitle, style: AppText.logo, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        l10n.homeSubtitle,
                        style: AppText.subtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(Routes.catalog),
                        child: Text(l10n.homeStart),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
