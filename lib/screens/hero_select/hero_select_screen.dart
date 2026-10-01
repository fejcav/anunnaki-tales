import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../models/character.dart';
import '../../models/local_data.dart';
import '../../services/auth_service.dart';
import '../../services/story_api.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/narrator_loading.dart';
import '../../widgets/stars_background.dart';
import '../gameplay/gameplay_screen.dart';

// "Elige tu héroe": grilla con los héroes jugables de la aventura (o una sola
// tarjeta "Viajero" si no tiene ninguno). "Empezar" pide la primera escena,
// guarda la partida en el teléfono y abre Gameplay.
class HeroSelectScreen extends StatefulWidget {
  const HeroSelectScreen({super.key});

  @override
  State<HeroSelectScreen> createState() => _HeroSelectScreenState();
}

class _HeroSelectScreenState extends State<HeroSelectScreen> {
  Adventure? _adventure; // llega como argumento de la ruta
  late Future<List<Character>> _heroes;
  int? _selected; // posición del héroe marcado en la grilla
  bool _starting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los argumentos de la ruta no se pueden leer en initState.
    if (_adventure == null) {
      _adventure = ModalRoute.of(context)!.settings.arguments as Adventure;
      _load();
    }
  }

  void _load() {
    _heroes = context.read<StoryApi>().fetchHeroes(_adventure!.id);
  }

  void _retry() => setState(_load);

  // `heroName` es el nombre del héroe marcado, o "Viajero" si no hay héroes.
  Future<void> _start(String heroName) async {
    final adventure = _adventure!;
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final userId = context.read<AuthService>().currentUserId;
    final api = context.read<StoryApi>();
    final store = context.read<LocalStore>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final title = adventure.title(lang);

    setState(() => _starting = true);
    try {
      if (userId == null) throw StateError('sin sesión');
      final scene = await api.startAdventure(
        userId: userId,
        mythId: adventure.mythId,
        heroName: heroName,
        language: lang,
      );
      await store.saveGame(
        SavedGame(
          userId: userId,
          sessionId: scene.sessionId!,
          adventureId: adventure.id,
          mythId: adventure.mythId,
          adventureTitle: title,
          heroName: heroName,
        ),
      );
      // Gameplay queda directamente sobre Inicio: la flecha atrás vuelve ahí.
      navigator.pushNamedAndRemoveUntil(
        Routes.gameplay,
        ModalRoute.withName(Routes.home),
        arguments: GameplayArgs(adventureTitle: title, scene: scene),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _starting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.heroStartError),
          action: SnackBarAction(label: l10n.retry, onPressed: () => _start(heroName)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.heroSelectTitle)),
      body: StarsBackground(
        child: FutureBuilder<List<Character>>(
          future: _heroes,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _Centered(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.heroError, style: AppText.body, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: _retry, child: Text(l10n.retry)),
                  ],
                ),
              );
            }
            if (_starting) {
              return _Centered(child: NarratorLoading(text: l10n.heroPreparing));
            }
            final heroes = snapshot.data!;
            // Sin héroes jugables: una sola tarjeta "Viajero".
            final names = heroes.isEmpty
                ? [l10n.heroTraveler]
                : heroes.map((h) => h.name).toList();
            final descriptions = heroes.isEmpty
                ? [l10n.heroTravelerDescription]
                : heroes.map((h) => h.description(lang)).toList();
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 175,
                    ),
                    itemCount: names.length,
                    itemBuilder: (context, i) => HeroCard(
                      name: names[i],
                      description: descriptions[i],
                      selected: _selected == i,
                      onTap: () => setState(() => _selected = i),
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
                        onPressed: _selected == null ? null : () => _start(names[_selected!]),
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

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: child),
    );
  }
}
