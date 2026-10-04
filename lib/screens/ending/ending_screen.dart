import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/story_rules.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../models/local_data.dart';
import '../../models/story.dart';
import '../../widgets/historical_fact_card.dart';
import '../../widgets/stars_background.dart';
import '../gameplay/gameplay_screen.dart';

// Lo que recibe Final: la aventura, su historia y el camino completo (el
// último id es el final al que llegó).
class EndingArgs {
  const EndingArgs({required this.adventure, required this.story, required this.path});

  final Adventure adventure;
  final Story story;
  final List<String> path;
}

// Final: tipo, título, texto, dato histórico, "Finales descubiertos: N de M"
// y los botones "Volver a jugar", "Otra aventura" y, solo en los finales
// trágicos, "Volver a la última decisión". El final ya quedó guardado como
// descubierto (lo hace Gameplay). No tiene flecha atrás.
class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key});

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> {
  EndingArgs? _args; // llega como argumento de la ruta
  int? _found; // finales descubiertos de esta aventura

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los argumentos de la ruta no se pueden leer en initState.
    if (_args == null) {
      _args = ModalRoute.of(context)!.settings.arguments as EndingArgs;
      _loadFound();
    }
  }

  Future<void> _loadFound() async {
    final data = await context.read<LocalStore>().load();
    if (mounted) setState(() => _found = data.endingsOf(_args!.adventure.id).length);
  }

  // Abre Gameplay con este camino y lo guarda como partida en curso.
  Future<void> _play(List<String> path) async {
    final args = _args!;
    final navigator = Navigator.of(context);
    await context.read<LocalStore>().saveGame(
      SavedGame(adventureId: args.adventure.id, sceneId: path.last, path: path),
    );
    navigator.pushReplacementNamed(
      Routes.gameplay,
      arguments: GameplayArgs(adventure: args.adventure, story: args.story, path: path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final args = _args!;
    final scene = args.story.scene(args.path.last)!;
    final ending = scene.ending!;
    final fact = scene.fact?.of(lang) ?? '';
    final lastDecision = ending.type == 'tragic'
        ? pathToLastDecision(args.story, args.path)
        : null;
    final typeLabel = switch (ending.type) {
      'myth' => l10n.endingTypeMyth,
      'tragic' => l10n.endingTypeTragic,
      _ => l10n.endingTypeAlternative,
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(args.adventure.title.of(lang)),
      ),
      body: StarsBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  typeLabel.toUpperCase(),
                  style: AppText.subtitle.copyWith(
                    color: ending.type == 'tragic' ? AppColors.riskHigh : AppColors.softGold,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(ending.title.of(lang), style: AppText.title, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                StoryText(text: scene.text.of(lang)),
                if (fact.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HistoricalFactCard(title: l10n.historicalFactTitle, fact: fact),
                ],
                const SizedBox(height: 20),
                if (_found != null)
                  Text(
                    l10n.endingFound(_found!, endingsOf(args.story).length),
                    style: AppText.body.copyWith(color: AppColors.softGold),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                if (lastDecision != null) ...[
                  ElevatedButton(
                    onPressed: () => _play(lastDecision),
                    child: Text(l10n.endingLastDecision),
                  ),
                  const SizedBox(height: 12),
                ],
                // El botón principal (dorado) es el primero de la lista.
                if (lastDecision == null)
                  ElevatedButton(
                    onPressed: () => _play([args.story.start]),
                    child: Text(l10n.endingPlayAgain),
                  )
                else
                  OutlinedButton(
                    onPressed: () => _play([args.story.start]),
                    child: Text(l10n.endingPlayAgain),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.catalog),
                  child: Text(l10n.endingOtherAdventure),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
