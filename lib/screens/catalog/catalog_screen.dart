import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../services/story_api.dart';
import '../../widgets/adventure_card.dart';
import '../../widgets/stars_background.dart';

// "Elige tu aventura": una tarjeta por aventura activa. Muestra una ruedita
// mientras carga, un aviso con "Reintentar" si falla y un texto si no hay
// ninguna.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Adventure>> _adventures;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _adventures = context.read<StoryApi>().fetchAdventures();
  }

  void _retry() => setState(_load);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      body: StarsBackground(
        child: FutureBuilder<List<Adventure>>(
          future: _adventures,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _Message(
                text: l10n.catalogError,
                action: OutlinedButton(onPressed: _retry, child: Text(l10n.retry)),
              );
            }
            final adventures = snapshot.data!;
            if (adventures.isEmpty) return _Message(text: l10n.catalogEmpty);
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: adventures.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => AdventureCard(
                adventure: adventures[i],
                onTap: () => Navigator.of(context)
                    .pushNamed(Routes.heroSelect, arguments: adventures[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: AppText.body, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
