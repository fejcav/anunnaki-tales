import 'package:anunnakitales/logic/choice_limit_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final morning = DateTime(2026, 10, 1, 9, 30);
  final lateNight = DateTime(2026, 10, 1, 23, 59);
  final afterMidnight = DateTime(2026, 10, 2, 0, 1);

  group('dayKey', () {
    test('formato yyyy-MM-dd con ceros', () {
      expect(dayKey(DateTime(2026, 3, 5, 12)), '2026-03-05');
      expect(dayKey(DateTime(2026, 12, 31, 23, 59)), '2026-12-31');
    });
  });

  group('choicesLeftToday', () {
    test('sin elecciones guardadas quedan 3', () {
      expect(choicesLeftToday(used: 0, lastDay: null, now: morning), 3);
    });

    test('descuenta las de hoy', () {
      expect(choicesLeftToday(used: 1, lastDay: '2026-10-01', now: morning), 2);
      expect(choicesLeftToday(used: 3, lastDay: '2026-10-01', now: lateNight), 0);
    });

    test('nunca da menos de 0', () {
      expect(choicesLeftToday(used: 7, lastDay: '2026-10-01', now: morning), 0);
    });

    test('se reinicia a medianoche', () {
      expect(choicesLeftToday(used: 3, lastDay: '2026-10-01', now: afterMidnight), 3);
    });

    test('las de un día viejo no cuentan', () {
      expect(choicesLeftToday(used: 3, lastDay: '2026-09-15', now: morning), 3);
    });
  });

  group('canChoose', () {
    test('gratis con elecciones disponibles', () {
      expect(canChoose(isPremium: false, used: 2, lastDay: '2026-10-01', now: morning), isTrue);
    });

    test('gratis sin elecciones', () {
      expect(canChoose(isPremium: false, used: 3, lastDay: '2026-10-01', now: morning), isFalse);
    });

    test('gratis sin elecciones, al día siguiente puede de nuevo', () {
      expect(
        canChoose(isPremium: false, used: 3, lastDay: '2026-10-01', now: afterMidnight),
        isTrue,
      );
    });

    test('Premium no tiene límite', () {
      expect(canChoose(isPremium: true, used: 50, lastDay: '2026-10-01', now: morning), isTrue);
    });
  });

  group('recordChoice', () {
    test('suma una el mismo día', () {
      final r = recordChoice(used: 1, lastDay: '2026-10-01', now: morning);
      expect(r.used, 2);
      expect(r.day, '2026-10-01');
    });

    test('la primera del día empieza en 1 aunque ayer se usaran todas', () {
      final r = recordChoice(used: 3, lastDay: '2026-10-01', now: afterMidnight);
      expect(r.used, 1);
      expect(r.day, '2026-10-02');
    });

    test('tres elecciones seguidas agotan el día', () {
      var used = 0;
      String? day;
      for (var i = 0; i < 3; i++) {
        final r = recordChoice(used: used, lastDay: day, now: morning);
        used = r.used;
        day = r.day;
      }
      expect(choicesLeftToday(used: used, lastDay: day, now: morning), 0);
      expect(canChoose(isPremium: false, used: used, lastDay: day, now: morning), isFalse);
    });
  });
}
