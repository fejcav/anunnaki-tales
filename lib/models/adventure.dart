// Una aventura del catálogo (tabla `adventures` de Supabase). Los textos
// vienen en los dos idiomas; la pantalla elige con el código del idioma activo.
class Adventure {
  const Adventure({
    required this.id,
    required this.mythId,
    required this.titleEs,
    required this.titleEn,
    required this.subtitleEs,
    required this.subtitleEn,
    required this.difficulty,
    required this.estimatedTurns,
  });

  final String id;
  final String mythId;
  final String titleEs;
  final String titleEn;
  final String subtitleEs;
  final String subtitleEn;
  final String difficulty; // easy | medium | hard
  final int estimatedTurns;

  factory Adventure.fromMap(Map<String, dynamic> map) {
    return Adventure(
      id: map['id'] as String,
      mythId: map['myth_id'] as String,
      titleEs: map['title_es'] as String? ?? '',
      titleEn: map['title_en'] as String? ?? '',
      subtitleEs: map['subtitle_es'] as String? ?? '',
      subtitleEn: map['subtitle_en'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? '',
      estimatedTurns: (map['estimated_turns'] as num?)?.toInt() ?? 0,
    );
  }

  // Si falta el texto en inglés, se usa el español.
  String title(String languageCode) =>
      languageCode == 'en' && titleEn.isNotEmpty ? titleEn : titleEs;

  String subtitle(String languageCode) =>
      languageCode == 'en' && subtitleEn.isNotEmpty ? subtitleEn : subtitleEs;
}
