import 'dart:ui';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';

// Color y etiqueta de la dificultad de una aventura (catálogo). Un valor
// desconocido se trata como dificultad media.

Color difficultyColor(String difficulty) {
  return switch (difficulty) {
    'easy' => AppColors.riskLow,
    'hard' => AppColors.riskHigh,
    _ => AppColors.riskMedium,
  };
}

String difficultyLabel(AppLocalizations l10n, String difficulty) {
  return switch (difficulty) {
    'easy' => l10n.difficultyEasy,
    'hard' => l10n.difficultyHard,
    _ => l10n.difficultyMedium,
  };
}

// Color y etiqueta del riesgo de una opción (Gameplay). Un valor desconocido
// se trata como riesgo medio.

Color riskColor(String riskLevel) {
  return switch (riskLevel) {
    'low' => AppColors.riskLow,
    'high' => AppColors.riskHigh,
    _ => AppColors.riskMedium,
  };
}

String riskLabel(AppLocalizations l10n, String riskLevel) {
  return switch (riskLevel) {
    'low' => l10n.riskLow,
    'high' => l10n.riskHigh,
    _ => l10n.riskMedium,
  };
}
