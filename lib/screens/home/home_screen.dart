import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/story_rules.dart';
import '../../main.dart';
import '../../services/story_repository.dart';
import '../../widgets/stars_background.dart';
import '../gameplay/gameplay_screen.dart';

// Inicio: título, "Comenzar aventura", "Continuar partida" (solo si hay una
// partida guardada cuya historia y escena existen, con el título de la
// aventura debajo) y el ícono de Ajustes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  GameplayArgs? _resume; // la partida guardada lista para abrir, o null

  @override
  void initState() {
    super.initState();
    _readSavedGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Se cerró la pantalla de arriba (Gameplay, Final, Catálogo…): la partida
  // guardada puede haber cambiado.
  @override
  void didPopNext() => _readSavedGame();

  Future<void> _readSavedGame() async {
    final repo = context.read<StoryRepository>();
    final game = (await context.read<LocalStore>().load()).savedGame;
    GameplayArgs? resume;
    if (game != null) {
      final story = await repo.loadStory(game.adventureId);
      final adventures = await repo.loadCatalog();
      final matches = adventures.where((a) => a.id == game.adventureId);
      if (story != null && matches.isNotEmpty && canResume(story, game.sceneId, game.path)) {
        resume = GameplayArgs(adventure: matches.first, story: story, path: game.path);
      }
    }
    if (mounted) setState(() => _resume = resume);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final resume = _resume;
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
                      if (resume != null) ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.gameplay, arguments: resume),
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
