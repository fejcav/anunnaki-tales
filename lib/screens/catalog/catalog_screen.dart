import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/story_rules.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../models/story.dart';
import '../../services/story_repository.dart';
import '../../widgets/adventure_card.dart';
import '../../widgets/stars_background.dart';

// Una aventura del catálogo con su historia (null si todavía no está escrita)
// y los finales que ya descubrió.
class _Entry {
  const _Entry(this.adventure, this.story, this.endingsFound);

  final Adventure adventure;
  final Story? story;
  final int endingsFound;
}

// "Elige tu aventura": una tarjeta por aventura del catálogo local. Las que
// tienen historia se abren en "Tu héroe"; las demás dicen "Próximamente".
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final Future<List<_Entry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _load();
  }

  Future<List<_Entry>> _load() async {
    final repo = context.read<StoryRepository>();
    final local = await context.read<LocalStore>().load();
    final adventures = await repo.loadCatalog();
    return [
      for (final a in adventures)
        _Entry(a, await repo.loadStory(a.id), local.endingsOf(a.id).length),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      body: StarsBackground(
        child: FutureBuilder<List<_Entry>>(
          future: _entries,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return _Message(text: l10n.catalogError);
            final entries = snapshot.data!;
            if (entries.isEmpty) return _Message(text: l10n.catalogEmpty);
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final entry = entries[i];
                final story = entry.story;
                return AdventureCard(
                  adventure: entry.adventure,
                  scenes: story == null
                      ? null
                      : shortestPathToMythEnding(story) ?? story.scenes.length,
                  endingsFound: entry.endingsFound,
                  endingsTotal: story == null ? 0 : endingsOf(story).length,
                  onTap: () => Navigator.of(context)
                      .pushNamed(Routes.heroIntro, arguments: entry.adventure),
                );
              },
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
