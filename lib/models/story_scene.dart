import 'localized_text.dart';

// Una escena de una historia (ver docs/formato-historias.md). Los finales
// tienen `ending` y ninguna opción.
class StoryScene {
  const StoryScene({
    required this.id,
    required this.chapter,
    required this.mood,
    required this.text,
    required this.choices,
    this.fact,
    this.ending,
  });

  final String id;
  final int chapter;
  final String mood;
  final LocalizedText text;
  final LocalizedText? fact; // "Dato histórico", opcional
  final List<StoryChoice> choices;
  final StoryEnding? ending; // solo en los finales

  factory StoryScene.fromJson(Map<String, dynamic> json) {
    final choices = json['choices'] as List? ?? const [];
    final ending = json['ending'];
    return StoryScene(
      id: json['id'] as String? ?? '',
      chapter: (json['chapter'] as num?)?.toInt() ?? 0,
      mood: json['mood'] as String? ?? '',
      text: LocalizedText.fromJson(json['text']),
      fact: json['fact'] == null ? null : LocalizedText.fromJson(json['fact']),
      choices: choices
          .map((c) => StoryChoice.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
      ending: ending == null
          ? null
          : StoryEnding.fromJson(Map<String, dynamic>.from(ending as Map)),
    );
  }
}

// Una opción de una escena: a qué escena lleva, su riesgo (puede faltar si es
// la única opción), el texto del botón y una oración que la explica.
class StoryChoice {
  const StoryChoice({
    required this.to,
    required this.text,
    required this.description,
    this.risk,
  });

  final String to;
  final String? risk; // low | medium | high, o null
  final LocalizedText text;
  final LocalizedText description;

  factory StoryChoice.fromJson(Map<String, dynamic> json) {
    return StoryChoice(
      to: json['to'] as String? ?? '',
      risk: json['risk'] as String?,
      text: LocalizedText.fromJson(json['text']),
      description: LocalizedText.fromJson(json['description']),
    );
  }
}

// El final de una historia: tipo y título.
class StoryEnding {
  const StoryEnding({required this.type, required this.title});

  final String type; // myth | alternative | tragic
  final LocalizedText title;

  factory StoryEnding.fromJson(Map<String, dynamic> json) {
    return StoryEnding(
      type: json['type'] as String? ?? '',
      title: LocalizedText.fromJson(json['title']),
    );
  }
}
