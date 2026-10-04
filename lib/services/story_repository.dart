import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/adventure.dart';
import '../models/story.dart';

// ÚNICA clase que lee assets/data: el catálogo (catalog.json) y las historias
// (stories/<id>.json). Lo leído queda en memoria para no releerlo.
class StoryRepository {
  List<Adventure>? _catalog;
  final Map<String, Story?> _stories = {};

  // Todas las aventuras, en el orden del catálogo.
  Future<List<Adventure>> loadCatalog() async {
    final cached = _catalog;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/data/catalog.json');
    final list = (jsonDecode(raw) as List)
        .map((a) => Adventure.fromJson(Map<String, dynamic>.from(a as Map)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return _catalog = list;
  }

  // La historia de una aventura, o null si todavía no tiene archivo
  // ("Próximamente").
  Future<Story?> loadStory(String adventureId) async {
    if (_stories.containsKey(adventureId)) return _stories[adventureId];
    Story? story;
    try {
      final raw = await rootBundle.loadString('assets/data/stories/$adventureId.json');
      story = Story.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FlutterError {
      story = null; // el archivo no existe
    }
    return _stories[adventureId] = story;
  }
}
