import 'dart:convert';

import 'package:anunnakitales/data/local_store.dart';
import 'package:anunnakitales/models/local_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const game = SavedGame(
    adventureId: 'gilgamesh_enkidu',
    sceneId: 'c1_shamhat',
    path: ['c1_uruk', 'c1_shamhat'],
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('guarda y lee la partida y los finales descubiertos', () async {
    final store = LocalStore();
    await store.save(
      const LocalData(
        language: 'en',
        savedGame: game,
        endingsFound: {
          'gilgamesh_enkidu': ['fin_polvo'],
        },
      ),
    );

    final data = await store.load();

    expect(data.language, 'en');
    expect(data.savedGame!.adventureId, 'gilgamesh_enkidu');
    expect(data.savedGame!.sceneId, 'c1_shamhat');
    expect(data.savedGame!.path, ['c1_uruk', 'c1_shamhat']);
    expect(data.endingsOf('gilgamesh_enkidu'), ['fin_polvo']);
    expect(data.endingsOf('descent_inanna'), isEmpty);
  });

  test('guarda y lee la compra; sin el campo, no hay compra', () async {
    final store = LocalStore();
    expect((await store.load()).purchased, isFalse);

    await store.save(const LocalData().withPurchased(true));

    expect((await store.load()).purchased, isTrue);
  });

  test('un final se guarda una sola vez y borra la partida', () {
    var data = const LocalData(savedGame: game);
    for (final ending in ['fin_tirano', 'fin_tirano', 'fin_polvo']) {
      data = data.withEndingFound('gilgamesh_enkidu', ending).withSavedGame(null);
    }

    expect(data.savedGame, isNull);
    expect(data.endingsOf('gilgamesh_enkidu'), ['fin_tirano', 'fin_polvo']);
  });

  test('borrar la partida conserva los finales y la compra', () {
    const before = LocalData(
      savedGame: game,
      endingsFound: {
        'gilgamesh_enkidu': ['fin_paz'],
      },
      purchased: true,
    );

    final data = before.withSavedGame(null);

    expect(data.savedGame, isNull);
    expect(data.endingsOf('gilgamesh_enkidu'), ['fin_paz']);
    expect(data.purchased, isTrue);
  });

  test('borrar progreso borra la partida y los finales; quedan el idioma y la compra', () {
    const before = LocalData(
      language: 'en',
      savedGame: game,
      endingsFound: {
        'gilgamesh_enkidu': ['fin_paz'],
      },
      purchased: true,
    );

    final data = before.withoutProgress();

    expect(data.language, 'en');
    expect(data.savedGame, isNull);
    expect(data.endingsFound, isEmpty);
    expect(data.purchased, isTrue);
  });

  test('la versión 1 descarta la partida vieja y el contador, y conserva el idioma', () async {
    SharedPreferences.setMockInitialValues({
      'localData': jsonEncode({
        'schemaVersion': 1,
        'dailyChoicesUsed': 3,
        'lastChoiceDay': '2026-10-02',
        'language': 'en',
        'savedGame': {
          'userId': 'u1',
          'sessionId': 's1',
          'adventureId': 'gilgamesh_enkidu',
          'mythId': 'gilgamesh_enkidu',
          'adventureTitle': 'El Hombre Salvaje de Uruk',
          'heroName': 'Gilgamesh',
        },
      }),
    });
    final store = LocalStore();
    final data = await store.load();

    expect(data.savedGame, isNull);
    expect(data.endingsFound, isEmpty);
    expect(data.language, 'en');

    // Al volver a guardar queda en la versión 2, sin el contador.
    await store.save(data);
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonDecode(prefs.getString('localData')!) as Map<String, dynamic>;
    expect(raw['schemaVersion'], 2);
    expect(raw.containsKey('dailyChoicesUsed'), isFalse);
  });

  test('un JSON roto se descarta y se empieza de cero', () async {
    SharedPreferences.setMockInitialValues({'localData': '{no es json'});
    final data = await LocalStore().load();

    expect(data.savedGame, isNull);
    expect(data.endingsFound, isEmpty);
  });
}
