import 'package:anunnakitales/data/local_store.dart';
import 'package:anunnakitales/models/local_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const game = SavedGame(
    userId: 'u1',
    sessionId: 's1',
    adventureId: 'a1',
    mythId: 'gilgamesh',
    adventureTitle: 'La epopeya',
    heroName: 'Gilgamesh',
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('clearAll borra la partida y el idioma pero conserva el contador del día', () async {
    final store = LocalStore();
    await store.save(
      const LocalData(
        dailyChoicesUsed: 3,
        lastChoiceDay: '2026-10-02',
        language: 'en',
        savedGame: game,
      ),
    );

    await store.clearAll();
    final data = await store.load();

    expect(data.dailyChoicesUsed, 3);
    expect(data.lastChoiceDay, '2026-10-02');
    expect(data.savedGame, isNull);
    expect(data.language, isNull);
  });

  test('clearGame borra solo la partida', () async {
    final store = LocalStore();
    await store.save(
      const LocalData(dailyChoicesUsed: 2, lastChoiceDay: '2026-10-02', savedGame: game),
    );

    await store.clearGame();
    final data = await store.load();

    expect(data.dailyChoicesUsed, 2);
    expect(data.savedGame, isNull);
  });

  test('un JSON roto se descarta y se empieza de cero', () async {
    SharedPreferences.setMockInitialValues({'localData': '{no es json'});
    final data = await LocalStore().load();

    expect(data.dailyChoicesUsed, 0);
    expect(data.savedGame, isNull);
  });
}
