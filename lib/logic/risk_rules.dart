import '../l10n/app_localizations.dart';

// Nivel de riesgo de una opción o de dificultad de una aventura. El color lo
// pone la pantalla, según el tema (`context.palette.risk(nivel)`).
enum RiskLevel { low, medium, high }

// Nivel y etiqueta de la dificultad de una aventura (catálogo). Un valor
// desconocido se trata como dificultad media.

RiskLevel difficultyLevel(String difficulty) {
  return switch (difficulty) {
    'easy' => RiskLevel.low,
    'hard' => RiskLevel.high,
    _ => RiskLevel.medium,
  };
}

String difficultyLabel(AppLocalizations l10n, String difficulty) {
  return switch (difficulty) {
    'easy' => l10n.difficultyEasy,
    'hard' => l10n.difficultyHard,
    _ => l10n.difficultyMedium,
  };
}

// Nivel y etiqueta del riesgo de una opción (Gameplay). Un valor desconocido
// se trata como riesgo medio.

RiskLevel riskLevelOf(String riskLevel) {
  return switch (riskLevel) {
    'low' => RiskLevel.low,
    'high' => RiskLevel.high,
    _ => RiskLevel.medium,
  };
}

String riskLabel(AppLocalizations l10n, String riskLevel) {
  return switch (riskLevel) {
    'low' => l10n.riskLow,
    'high' => l10n.riskHigh,
    _ => l10n.riskMedium,
  };
}
