import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/adventure.dart';

// ÚNICA clase que lee tablas de Supabase y llama a la Edge Function narrative.
// Si algo falla deja pasar el error: la pantalla muestra su aviso con
// "Reintentar".
class StoryApi {
  SupabaseClient get _db => Supabase.instance.client;

  static const _timeout = Duration(seconds: 15);

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
}
