import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/risk_rules.dart';
import '../../logic/story_rules.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../models/local_data.dart';
import '../../models/story.dart';
import '../../models/story_scene.dart';
import '../../state/app_state.dart';
import '../../widgets/choice_button.dart';
import '../../widgets/historical_fact_card.dart';
import '../../widgets/stars_background.dart';
import '../ending/ending_screen.dart';

// Lo que recibe Gameplay al abrirse: la aventura, su historia y el camino de
// la partida (ids de las escenas vistas; la última es la actual).
class GameplayArgs {
  const GameplayArgs({required this.adventure, required this.story, required this.path});

  final Adventure adventure;
  final Story story;
  final List<String> path;
}

// Gameplay: "Capítulo N · Título", "Turno N", el texto de la escena en
// párrafos, el dato histórico (si tiene) y las opciones. Elegir es
// instantáneo y la partida se guarda en cada escena. Al llegar a un final se
// guarda como descubierto y se abre la pantalla de Final. La flecha atrás
// vuelve a Inicio.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  final _scroll = ScrollController();
  GameplayArgs? _args; // llega como argumento de la ruta
  late List<String> _path;
  bool _busy = false; // guardando la elección (evita un doble toque)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los argumentos de la ruta no se pueden leer en initState.
    if (_args == null) {
      _args = ModalRoute.of(context)!.settings.arguments as GameplayArgs;
      _path = List.of(_args!.path);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _choose(StoryChoice choice) async {
    final args = _args!;
    final next = nextScene(args.story, choice);
    if (next == null || _busy) return; // null no pasa: la validación lo impide
    _busy = true;
    final store = context.read<AppState>();
    final navigator = Navigator.of(context);
    final path = [..._path, next.id];

    if (isEnding(next)) {
      await store.finishGame(args.adventure.id, next.id);
      navigator.pushReplacementNamed(
        Routes.ending,
        arguments: EndingArgs(adventure: args.adventure, story: args.story, path: path),
      );
      return;
    }

    await store.saveGame(SavedGame(adventureId: args.adventure.id, sceneId: next.id, path: path));
    _busy = false;
    if (!mounted) return;
    setState(() => _path = path);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final args = _args!;
    final scene = args.story.scene(_path.last)!;
    final chapterTitle = args.story.chapters[scene.chapter]?.of(lang) ?? '';
    final fact = scene.fact?.of(lang) ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(args.adventure.title.of(lang))),
      body: StarsBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  chapterTitle.isEmpty
                      ? l10n.gameplayChapterNumber(scene.chapter)
                      : l10n.gameplayChapter(scene.chapter, chapterTitle),
                  style: AppText.subtitle.copyWith(color: AppColors.gold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.gameplayTurn(_path.length),
                  style: AppText.bodySecondary.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                StoryText(text: scene.text.of(lang)),
                if (fact.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HistoricalFactCard(title: l10n.historicalFactTitle, fact: fact),
                ],
                const SizedBox(height: 24),
                for (final choice in scene.choices) ...[
                  ChoiceButton(
                    text: choice.text.of(lang),
                    description: choice.description.of(lang),
                    riskColor: choice.risk == null ? null : riskColor(choice.risk!),
                    riskLabel: choice.risk == null ? null : riskLabel(l10n, choice.risk!),
                    onTap: () => _choose(choice),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// El texto de una escena en Lora, un párrafo por cada bloque separado por una
// línea en blanco. También lo usa la pantalla de Final.
class StoryText extends StatelessWidget {
  const StoryText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, p) in paragraphs.indexed) ...[
          if (i > 0) const SizedBox(height: 14),
          Text(p, style: AppText.narrative),
        ],
      ],
    );
  }
}
