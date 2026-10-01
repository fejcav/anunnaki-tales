// Una de las tres opciones de una escena. `id` es el número que se manda a la
// función narrative al elegirla.
class Choice {
  const Choice({
    required this.id,
    required this.text,
    required this.description,
    required this.riskLevel,
  });

  final int id;
  final String text;
  final String description;
  final String riskLevel; // low | medium | high

  factory Choice.fromMap(Map<String, dynamic> map) {
    return Choice(
      id: (map['id'] as num).toInt(),
      text: map['text'] as String? ?? '',
      description: map['description'] as String? ?? '',
      riskLevel: map['risk_level'] as String? ?? '',
    );
  }
}
