import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/risk_rules.dart';
import '../models/adventure.dart';

// Tarjeta de una aventura en el Catálogo: título, subtítulo, dificultad con
// su color y "~N escenas"; debajo, "Finales: N de M" si ya descubrió alguno.
// Sin historia escrita (`scenes` null) muestra "Próximamente", se ve apagada
// y no se puede tocar. Con candado (`locked`) muestra un candado junto al
// título; tocarla abre el Paywall.
class AdventureCard extends StatelessWidget {
  const AdventureCard({
    super.key,
    required this.adventure,
    required this.scenes,
    required this.locked,
    required this.endingsFound,
    required this.endingsTotal,
    required this.onTap,
  });

  final Adventure adventure;
  final int? scenes; // camino más corto al final del mito; null = sin historia
  final bool locked; // no es gratis y no se hizo la compra
  final int endingsFound;
  final int endingsTotal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final color = context.palette.risk(difficultyLevel(adventure.difficulty));
    final comingSoon = scenes == null;
    return Opacity(
      opacity: comingSoon ? 0.55 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.palette.gold.withValues(alpha: 0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: comingSoon ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        adventure.title.of(lang),
                        style: context.appText.title.copyWith(fontSize: 18),
                      ),
                    ),
                    if (locked && !comingSoon) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock_outline,
                        color: context.palette.gold,
                        size: 20,
                        semanticLabel: l10n.catalogLocked,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(adventure.subtitle.of(lang), style: context.appText.bodySecondary),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      difficultyLabel(l10n, adventure.difficulty),
                      style: context.appText.body.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      comingSoon ? l10n.catalogComingSoon : l10n.catalogScenes(scenes!),
                      style: comingSoon
                          ? context.appText.body.copyWith(
                              color: context.palette.gold,
                              fontWeight: FontWeight.w600,
                            )
                          : context.appText.bodySecondary,
                    ),
                  ],
                ),
                if (endingsFound > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.catalogEndings(endingsFound, endingsTotal),
                    style: context.appText.body.copyWith(color: context.palette.softGold),
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
