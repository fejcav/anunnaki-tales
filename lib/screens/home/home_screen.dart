import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../models/local_data.dart';
import '../../services/auth_service.dart';
import '../../services/story_api.dart';
import '../../widgets/stars_background.dart';
import '../gameplay/gameplay_screen.dart';

// Inicio: título, "Comenzar aventura", "Continuar partida" (solo si hay una
// partida guardada del usuario con sesión abierta) y el ícono de perfil.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  SavedGame? _savedGame;
  bool _loadingGame = false; // esperando la respuesta de `load`

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

  // Se cerró la pantalla de arriba (Gameplay, Catálogo…): puede haber una
  // partida nueva guardada.
  @override
  void didPopNext() => _readSavedGame();

  Future<void> _readSavedGame() async {
    final userId = context.read<AuthService>().currentUserId;
    final data = await context.read<LocalStore>().load();
    final game = data.savedGame;
    if (!mounted) return;
    // Una partida de otro usuario no se muestra.
    setState(() => _savedGame = game != null && game.userId == userId ? game : null);
  }

  Future<void> _continue(SavedGame game) async {
    final l10n = AppLocalizations.of(context);
    final api = context.read<StoryApi>();
    final store = context.read<LocalStore>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    messenger.hideCurrentSnackBar();

    setState(() => _loadingGame = true);
    try {
      final scene = await api.loadAdventure(game.sessionId);
      if (!mounted) return;
      setState(() => _loadingGame = false);
      navigator.pushNamed(
        Routes.gameplay,
        arguments: GameplayArgs(adventureTitle: game.adventureTitle, scene: scene),
      );
    } on SavedGameNotFound {
      await store.clearGame();
      if (!mounted) return;
      setState(() {
        _loadingGame = false;
        _savedGame = null;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.homeGameNotFound)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingGame = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.homeContinueError),
          action: SnackBarAction(label: l10n.retry, onPressed: () => _continue(game)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = _savedGame;
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
                      if (game != null) ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _loadingGame ? null : () => _continue(game),
                          child: _loadingGame
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.homeContinue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.homeContinueDetail(game.adventureTitle, game.heroName),
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
