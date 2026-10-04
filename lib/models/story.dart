import 'localized_text.dart';
import 'story_scene.dart';

// La historia completa de una aventura (assets/data/stories/<id>.json):
// protagonista, capítulos, escena inicial y todas las escenas.
class Story {
  Story({
    required this.formatVersion,
    required this.adventureId,
    required this.heroName,
    required this.heroDescription,
    required this.chapters,
    required this.start,
    required this.scenes,
  }) : _byId = {for (final s in scenes) s.id: s};

  final int formatVersion;
  final String adventureId;
  final LocalizedText heroName;
  final LocalizedText heroDescription;
  final Map<int, LocalizedText> chapters; // número → título
  final String start;
  final List<StoryScene> scenes;
  final Map<String, StoryScene> _byId;

  // La escena con ese id, o null si no existe.
  StoryScene? scene(String id) => _byId[id];

  factory Story.fromJson(Map<String, dynamic> json) {
    final hero = json['hero'] is Map ? json['hero'] as Map : const {};
    final chapters = json['chapters'] as List? ?? const [];
    final scenes = json['scenes'] as List? ?? const [];
    return Story(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 0,
      adventureId: json['adventureId'] as String? ?? '',
      heroName: LocalizedText.fromJson(hero['name']),
      heroDescription: LocalizedText.fromJson(hero['description']),
      chapters: {
        for (final c in chapters.cast<Map>())
          (c['number'] as num).toInt(): LocalizedText.fromJson(c['title']),
      },
      start: json['start'] as String? ?? '',
      scenes: scenes
          .map((s) => StoryScene.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
    );
  }
}
