import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/adventure.dart';
import '../models/character.dart';
import '../models/story_scene.dart';

// ÚNICA clase que lee tablas de Supabase y llama a la Edge Function narrative.
// Si algo falla deja pasar el error: la pantalla muestra su aviso con
// "Reintentar".
class StoryApi {
  SupabaseClient get _db => Supabase.instance.client;

  static const _timeout = Duration(seconds: 15);
  // La IA tarda bastante más que una lectura de tabla.
  static const _narrativeTimeout = Duration(seconds: 60);

  // Aventuras activas, en el orden del catálogo.
  Future<List<Adventure>> fetchAdventures() async {
    final rows = await _db
        .from('adventures')
        .select()
        .eq('is_active', true)
        // En supabase_flutter, order() sin ascending ordena de mayor a menor.
        .order('sort_order', ascending: true)
        .timeout(_timeout);
    return rows.map(Adventure.fromMap).toList();
  }

  // Héroes jugables de una aventura. La tabla también vincula antagonistas y
  // aliados no jugables (Tiamat, Enki…): esos se descartan.
  Future<List<Character>> fetchHeroes(String adventureId) async {
    final rows = await _db
        .from('adventure_characters')
        .select('*, characters(*)')
        .eq('adventure_id', adventureId)
        .timeout(_timeout);
    return rows
        .map((row) => row['characters'] as Map<String, dynamic>?)
        .where((c) => c != null && c['is_playable'] == true)
        .map((c) => Character.fromMap(c!))
        .toList();
  }

  // Empieza una partida y devuelve la primera escena. Sin `session_id` la
  // partida no quedó guardada: se trata como error.
  Future<StoryScene> startAdventure({
    required String userId,
    required String mythId,
    required String heroName,
    required String language,
  }) async {
    final response = await _db.functions
        .invoke(
          'narrative',
          body: {
            'action': 'start',
            'user_id': userId,
            'myth_id': mythId,
            'player_name': heroName,
            'difficulty': 'normal',
            'language': language,
          },
        )
        .timeout(_narrativeTimeout);
    final scene = StoryScene.fromMap(
      Map<String, dynamic>.from(response.data as Map),
    );
    if (scene.sessionId == null) {
      throw StateError('narrative start sin session_id');
    }
    return scene;
  }

  // Manda la opción elegida y devuelve la escena siguiente. El idioma y la
  // dificultad los saca la función de la partida guardada.
  Future<StoryScene> continueAdventure({
    required String sessionId,
    required int choiceId,
  }) async {
    final response = await _db.functions
        .invoke(
          'narrative',
          body: {
            'action': 'continue',
            'session_id': sessionId,
            'choice_id': choiceId,
          },
        )
        .timeout(_narrativeTimeout);
    return StoryScene.fromMap(Map<String, dynamic>.from(response.data as Map));
  }
}
