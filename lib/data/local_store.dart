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

  // Reemplaza la partida guardada (empezar una aventura nueva pisa la anterior).
  Future<void> saveGame(SavedGame game) async {
    final data = await load();
    await save(data.withSavedGame(game));
  }

  // Borra la partida guardada (por ejemplo, si ya no existe en Supabase).
  Future<void> clearGame() async {
    final data = await load();
    await save(data.withSavedGame(null));
  }
}
