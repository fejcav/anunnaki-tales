import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/choice_limit_rules.dart';
import '../../logic/risk_rules.dart';
import '../../main.dart';
import '../../models/choice.dart';
import '../../models/local_data.dart';
import '../../models/story_scene.dart';
import '../../services/story_api.dart';
import '../../state/app_state.dart';
import '../../widgets/choice_button.dart';
import '../../widgets/historical_fact_card.dart';
import '../../widgets/narrator_loading.dart';
import '../../widgets/stars_background.dart';

// Lo que recibe Gameplay al abrirse: el título de la aventura y la escena.
class GameplayArgs {
  const GameplayArgs({required this.adventureTitle, required this.scene});

  final String adventureTitle;
  final StoryScene scene;
}

// Gameplay: turno, texto de la escena, dato histórico (si viene) y las tres
// opciones. Elegir una pide la escena siguiente; cada respuesta buena gasta
// una elección gratis del día. Sin elecciones, tocar una opción abre el
// Paywall. Premium no tiene límite ni ve el contador. La flecha atrás vuelve
// a Inicio y la partida queda guardada.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  final _scroll = ScrollController();
  GameplayArgs? _args; // llega como argumento de la ruta
  late StoryScene _scene;
  late String _sessionId;
  LocalData? _local; // contador de elecciones del día
  bool _thinking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los argumentos de la ruta no se pueden leer en initState.
    if (_args == null) {
      _args = ModalRoute.of(context)!.settings.arguments as GameplayArgs;
      _scene = _args!.scene;
      _sessionId = _scene.sessionId!;
      _loadLocal();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadLocal() async {
    final data = await context.read<LocalStore>().load();
    if (mounted) setState(() => _local = data);
  }

  Future<void> _choose(Choice choice) async {
    if (_thinking) return; // ya hay una elección en camino
    final l10n = AppLocalizations.of(context);
    final api = context.read<StoryApi>();
    final store = context.read<LocalStore>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final isPremium = context.read<AppState>().isPremium;
    // Un aviso de error anterior (queda fijo porque tiene "Reintentar") se
    // cierra al volver a elegir.
    messenger.hideCurrentSnackBar();

    // Se relee del teléfono por si cambió el día o el contador.
    final local = await store.load();
    final now = DateTime.now();
    if (!canChoose(
      isPremium: isPremium,
      used: local.dailyChoicesUsed,
      lastDay: local.lastChoiceDay,
      now: now,
    )) {
      // Si no compra, vuelve a la misma escena.
      await navigator.pushNamed(Routes.paywall);
      return;
    }

    if (!mounted) return;
    setState(() => _thinking = true);
    try {
      final next = await api.continueAdventure(sessionId: _sessionId, choiceId: choice.id);
      // La IA respondió bien: recién ahora se descuenta la elección (a
      // Premium no se le descuenta nada).
      var updated = local;
      if (!isPremium) {
        final counted = recordChoice(
          used: local.dailyChoicesUsed,
          lastDay: local.lastChoiceDay,
          now: DateTime.now(),
        );
        updated = local.withDailyChoices(used: counted.used, day: counted.day);
        await store.save(updated);
      }
      if (!mounted) return;
      setState(() {
        _scene = next;
        _local = updated;
        _thinking = false;
      });
      if (_scroll.hasClients) _scroll.jumpTo(0);
    } catch (_) {
      if (!mounted) return;
      setState(() => _thinking = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.gameplayChoiceError),
          action: SnackBarAction(label: l10n.retry, onPressed: () => _choose(choice)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fact = _scene.historicalFact;
    final local = _local;
    final isPremium = context.watch<AppState>().isPremium;
    return Scaffold(
      appBar: AppBar(title: Text(_args!.adventureTitle)),
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
                  l10n.gameplayTurn(_scene.turn),
                  style: AppText.subtitle.copyWith(color: AppColors.gold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(_scene.narrative, style: AppText.narrative),
                if (fact != null && fact.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  HistoricalFactCard(title: l10n.historicalFactTitle, fact: fact),
                ],
                const SizedBox(height: 24),
                if (_thinking)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: NarratorLoading(text: l10n.gameplayThinking),
                  )
                else
                  for (final choice in _scene.choices) ...[
                    ChoiceButton(
                      text: choice.text,
                      description: choice.description,
                      riskColor: riskColor(choice.riskLevel),
                      riskLabel: riskLabel(l10n, choice.riskLevel),
                      onTap: () => _choose(choice),
                    ),
                    const SizedBox(height: 12),
                  ],
                if (!isPremium && local != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.gameplayFreeChoices(
                      choicesLeftToday(
                        used: local.dailyChoicesUsed,
                        lastDay: local.lastChoiceDay,
                        now: DateTime.now(),
                      ),
                      dailyFreeChoices,
                    ),
                    style: AppText.bodySecondary.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
