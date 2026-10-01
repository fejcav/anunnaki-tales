import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/risk_rules.dart';
import '../models/adventure.dart';

// Tarjeta de una aventura en el Catálogo: título, subtítulo, dificultad con
// su color y la cantidad aproximada de turnos.
class AdventureCard extends StatelessWidget {
  const AdventureCard({super.key, required this.adventure, required this.onTap});

  final Adventure adventure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final color = difficultyColor(adventure.difficulty);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(adventure.title(lang), style: AppText.title.copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text(adventure.subtitle(lang), style: AppText.bodySecondary),
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
                    style: AppText.body.copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    l10n.catalogTurns(adventure.estimatedTurns),
                    style: AppText.bodySecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
