import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/purchase_rules.dart';
import '../../logic/story_rules.dart';
import '../../main.dart';
import '../../state/app_state.dart';
import '../../widgets/adventure_card.dart';
import '../../widgets/stars_background.dart';

// "Elige tu aventura": una tarjeta por aventura del catálogo local. Las
// abiertas van a "Tu héroe"; las que tienen candado (no gratis y sin la
// compra) abren el Paywall; las que no tienen historia dicen "Próximamente".
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final entries = state.adventures;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      body: StarsBackground(
        child: state.catalogFailed
            ? _Message(text: l10n.catalogError)
            : entries.isEmpty
            ? _Message(text: l10n.catalogEmpty)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final entry = entries[i];
                  final story = entry.story;
                  final locked = entry.status == AdventureStatus.locked;
                  return AdventureCard(
                    adventure: entry.adventure,
                    scenes: story == null
                        ? null
                        : shortestPathToMythEnding(story) ?? story.scenes.length,
                    locked: locked,
                    endingsFound: entry.endingsFound,
                    endingsTotal: story == null ? 0 : endingsOf(story).length,
                    onTap: () => Navigator.of(context).pushNamed(
                      locked ? Routes.paywall : Routes.heroIntro,
                      arguments: entry.adventure,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(text, style: AppText.body, textAlign: TextAlign.center),
      ),
    );
  }
}
