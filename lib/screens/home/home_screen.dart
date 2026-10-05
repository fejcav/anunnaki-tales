import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../state/app_state.dart';
import '../../widgets/stars_background.dart';
import '../gameplay/gameplay_screen.dart';

// Inicio: título, "Comenzar aventura", "Continuar partida" (solo si hay una
// partida guardada cuya historia y escena existen, con el título de la
// aventura debajo) y el ícono de Ajustes.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final resume = context.watch<AppState>().resume;
    return Scaffold(
      body: StarsBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppColors.gold),
                  tooltip: l10n.settingsTitle,
                  onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
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
                      Text(l10n.homeSubtitle, style: AppText.subtitle, textAlign: TextAlign.center),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(Routes.catalog),
                        child: Text(l10n.homeStart),
                      ),
                      if (resume != null) ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                            Routes.gameplay,
                            arguments: GameplayArgs(
                              adventure: resume.adventure,
                              story: resume.story,
                              path: resume.path,
                            ),
                          ),
                          child: Text(l10n.homeContinue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          resume.adventure.title.of(lang),
                          style: AppText.bodySecondary.copyWith(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
