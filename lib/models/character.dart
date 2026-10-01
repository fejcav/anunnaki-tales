// Un héroe que se puede elegir (tabla `characters` de Supabase). `title` está
// solo en inglés y no se muestra; se usa la descripción en el idioma activo.
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.descriptionEs,
    required this.descriptionEn,
  });

  final String id;
  final String name;
  final String descriptionEs;
  final String descriptionEn;

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      descriptionEs: map['description_es'] as String? ?? '',
      descriptionEn: map['description_en'] as String? ?? '',
    );
  }

  // Si falta el texto en inglés, se usa el español.
  String description(String languageCode) =>
      languageCode == 'en' && descriptionEn.isNotEmpty ? descriptionEn : descriptionEs;
}
