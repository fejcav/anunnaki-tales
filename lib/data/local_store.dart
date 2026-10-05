import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_data.dart';

// ÚNICA clase que toca shared_preferences. Guarda todo en un solo JSON bajo la
// clave `localData`. Si no se puede leer, se empieza de cero.
class LocalStore {
  static const _key = 'localData';

  Future<LocalData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const LocalData();
    try {
      return LocalData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const LocalData();
    }
  }

  Future<void> save(LocalData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  // Guarda la partida en curso (empezar una aventura nueva pisa la anterior).
  Future<void> saveGame(SavedGame game) async {
    final data = await load();
    await save(data.withSavedGame(game));
  }

  // Borra la partida guardada.
  Future<void> clearGame() async {
    final data = await load();
    await save(data.withSavedGame(null));
  }

  // Llegó a un final: lo guarda como descubierto y borra la partida.
  Future<void> finishGame(String adventureId, String endingId) async {
    final data = await load();
    await save(data.withEndingFound(adventureId, endingId).withSavedGame(null));
  }

  // "Borrar progreso" (Ajustes): borra la partida guardada y los finales
  // descubiertos. El idioma queda.
  Future<void> clearProgress() async {
    final data = await load();
    await save(LocalData(language: data.language));
  }
}
