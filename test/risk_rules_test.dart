import 'package:anunnakitales/l10n/app_localizations.dart';
import 'package:anunnakitales/logic/risk_rules.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('difficultyLevel', () {
    test('fácil verde, media naranja, difícil rojo', () {
      expect(difficultyLevel('easy'), RiskLevel.low);
      expect(difficultyLevel('medium'), RiskLevel.medium);
      expect(difficultyLevel('hard'), RiskLevel.high);
    });

    test('un valor desconocido se trata como media', () {
      expect(difficultyLevel(''), RiskLevel.medium);
      expect(difficultyLevel('legendary'), RiskLevel.medium);
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

  group('riskLevelOf', () {
    test('bajo verde, medio naranja, alto rojo', () {
      expect(riskLevelOf('low'), RiskLevel.low);
      expect(riskLevelOf('medium'), RiskLevel.medium);
      expect(riskLevelOf('high'), RiskLevel.high);
    });

    test('un valor desconocido se trata como medio', () {
      expect(riskLevelOf(''), RiskLevel.medium);
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
