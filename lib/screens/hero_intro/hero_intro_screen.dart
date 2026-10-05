import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../models/local_data.dart';
import '../../models/story.dart';
import '../../services/ads.dart';
import '../../state/app_state.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/stars_background.dart';
import '../gameplay/gameplay_screen.dart';

// "Tu héroe": presenta al protagonista de la aventura (nombre y descripción)
// y la aventura. "Empezar" guarda una partida nueva (pisa la anterior) y abre
// la primera escena; antes, sin la compra, pasa el intersticial si está listo
// (si no, sigue sin anuncio). Al pie, el banner.
class HeroIntroScreen extends StatelessWidget {
  const HeroIntroScreen({super.key});

  Future<void> _start(BuildContext context, Adventure adventure, Story story) async {
    final navigator = Navigator.of(context);
    final path = [story.start];
    await context.read<AppState>().saveGame(
      SavedGame(adventureId: adventure.id, sceneId: story.start, path: path),
    );
    if (!context.mounted) return;
    await context.read<AdsService>().showInterstitialIfReady();
    // Gameplay queda directamente sobre Inicio: la flecha atrás vuelve ahí.
    navigator.pushNamedAndRemoveUntil(
      Routes.gameplay,
      ModalRoute.withName(Routes.home),
      arguments: GameplayArgs(adventure: adventure, story: story, path: path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final adventure = ModalRoute.of(context)!.settings.arguments as Adventure;
    final story = context.read<AppState>().storyOf(adventure.id);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.heroIntroTitle)),
      body: StarsBackground(
        child: Builder(
          builder: (context) {
            if (story == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l10n.storyLoadError, style: AppText.body),
                ),
              );
            }
            final heroName = story.heroName.of(lang);
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.lapis,
                            child: Text(
                              heroName.isEmpty ? '?' : heroName.characters.first.toUpperCase(),
                              style: AppText.title.copyWith(fontSize: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(heroName, style: AppText.title, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(
                          story.heroDescription.of(lang),
                          style: AppText.narrative,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l10n.heroIntroAdventure,
                          style: AppText.bodySecondary.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          adventure.title.of(lang),
                          style: AppText.title.copyWith(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          adventure.description.of(lang),
                          style: AppText.bodySecondary.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _start(context, adventure, story),
                        child: Text(l10n.heroStart),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}
