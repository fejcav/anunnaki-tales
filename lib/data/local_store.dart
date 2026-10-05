import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_data.dart';

// ÚNICA clase que toca shared_preferences. Guarda todo en un solo JSON bajo la
// clave `localData`. Si no se puede leer, se empieza de cero. Qué se guarda lo
// decide AppState, que tiene los datos en memoria y los guarda enteros.
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
}
