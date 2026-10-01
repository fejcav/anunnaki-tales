import 'package:flutter/material.dart';

import '../app_theme.dart';

// Tarjeta "Dato histórico" debajo de la escena. Solo se muestra si la función
// narrative lo manda (hoy no lo manda).
class HistoricalFactCard extends StatelessWidget {
  const HistoricalFactCard({super.key, required this.title, required this.fact});

  final String title;
  final String fact;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(title, style: AppText.title.copyWith(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Text(fact, style: AppText.bodySecondary),
          ],
        ),
      ),
    );
  }
}
