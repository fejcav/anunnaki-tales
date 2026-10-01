import 'choice.dart';

// Una escena que devuelve la función narrative (acciones start, continue y
// load): el texto, el tono, las opciones, el número de turno y la partida.
class StoryScene {
  const StoryScene({
    required this.narrative,
    required this.mood,
    required this.choices,
    required this.turn,
    required this.sessionId,
    this.historicalFact,
  });

  final String narrative;
  final String mood;
  final List<Choice> choices;
  final int turn;
  final String? sessionId;
  final String? historicalFact; // hoy la función no lo manda

  factory StoryScene.fromMap(Map<String, dynamic> map) {
    final choices = map['choices'] as List? ?? const [];
    return StoryScene(
      narrative: map['narrative'] as String? ?? '',
      mood: map['scene_mood'] as String? ?? '',
      choices: choices
          .map((c) => Choice.fromMap(Map<String, dynamic>.from(c as Map)))
          .toList(),
      turn: (map['turn_count'] as num?)?.toInt() ?? 1,
      sessionId: map['session_id'] as String?,
      historicalFact: map['historical_fact'] as String?,
    );
  }
}
