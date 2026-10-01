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
}
