import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../models/local_data.dart';
import '../../models/story.dart';
import '../../services/story_repository.dart';
import '../../widgets/stars_background.dart';
import '../gameplay/gameplay_screen.dart';

// "Tu héroe": presenta al protagonista de la aventura (nombre y descripción)
// y la aventura. "Empezar" guarda una partida nueva (pisa la anterior) y abre
// la primera escena.
class HeroIntroScreen extends StatefulWidget {
  const HeroIntroScreen({super.key});

  @override
  State<HeroIntroScreen> createState() => _HeroIntroScreenState();
}

class _HeroIntroScreenState extends State<HeroIntroScreen> {
  Adventure? _adventure; // llega como argumento de la ruta
  late Future<Story?> _story;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los argumentos de la ruta no se pueden leer en initState.
    if (_adventure == null) {
      _adventure = ModalRoute.of(context)!.settings.arguments as Adventure;
      _story = context.read<StoryRepository>().loadStory(_adventure!.id);
    }
  }

  Future<void> _start(Story story) async {
    final adventure = _adventure!;
    final navigator = Navigator.of(context);
    final path = [story.start];
    await context.read<LocalStore>().saveGame(
      SavedGame(adventureId: adventure.id, sceneId: story.start, path: path),
    );
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
    final adventure = _adventure!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.heroIntroTitle)),
      body: StarsBackground(
        child: FutureBuilder<Story?>(
          future: _story,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final story = snapshot.data;
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
                        onPressed: () => _start(story),
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
    );
  }
}
