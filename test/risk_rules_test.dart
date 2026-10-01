import 'package:anunnakitales/app_theme.dart';
import 'package:anunnakitales/l10n/app_localizations.dart';
import 'package:anunnakitales/logic/risk_rules.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('difficultyColor', () {
    test('fácil verde, media naranja, difícil rojo', () {
      expect(difficultyColor('easy'), AppColors.riskLow);
      expect(difficultyColor('medium'), AppColors.riskMedium);
      expect(difficultyColor('hard'), AppColors.riskHigh);
    });

    test('un valor desconocido se trata como media', () {
      expect(difficultyColor(''), AppColors.riskMedium);
      expect(difficultyColor('legendary'), AppColors.riskMedium);
    });
  });

  group('difficultyLabel', () {
    final es = lookupAppLocalizations(const Locale('es'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('en español', () {
      expect(difficultyLabel(es, 'easy'), 'Fácil');
      expect(difficultyLabel(es, 'medium'), 'Media');
      expect(difficultyLabel(es, 'hard'), 'Difícil');
    });

    test('en inglés', () {
      expect(difficultyLabel(en, 'easy'), 'Easy');
      expect(difficultyLabel(en, 'medium'), 'Medium');
      expect(difficultyLabel(en, 'hard'), 'Hard');
    });

    test('un valor desconocido se trata como media', () {
      expect(difficultyLabel(es, 'otra'), 'Media');
    });
  });

  group('riskColor', () {
    test('bajo verde, medio naranja, alto rojo', () {
      expect(riskColor('low'), AppColors.riskLow);
      expect(riskColor('medium'), AppColors.riskMedium);
      expect(riskColor('high'), AppColors.riskHigh);
    });

    test('un valor desconocido se trata como medio', () {
      expect(riskColor(''), AppColors.riskMedium);
    });
  });

  group('riskLabel', () {
    final es = lookupAppLocalizations(const Locale('es'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('en español', () {
      expect(riskLabel(es, 'low'), 'Riesgo bajo');
      expect(riskLabel(es, 'medium'), 'Riesgo medio');
      expect(riskLabel(es, 'high'), 'Riesgo alto');
    });

    test('en inglés', () {
      expect(riskLabel(en, 'low'), 'Low risk');
      expect(riskLabel(en, 'medium'), 'Medium risk');
      expect(riskLabel(en, 'high'), 'High risk');
    });

    test('un valor desconocido se trata como medio', () {
      expect(riskLabel(es, 'x'), 'Riesgo medio');
    });
  });
}
