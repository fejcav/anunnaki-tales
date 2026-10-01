import 'package:flutter/material.dart';

import '../app_theme.dart';

// Aviso mientras la IA escribe: un texto en cursiva y una barra dorada que se
// mueve sin parar.
class NarratorLoading extends StatelessWidget {
  const NarratorLoading({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text,
          style: AppText.narrative.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.softGold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(minHeight: 4),
        ),
      ],
    );
  }
}
