// Un texto en los dos idiomas ({ "es": "…", "en": "…" } en los JSON de
// assets/data). Si falta el inglés, se muestra el español.
class LocalizedText {
  const LocalizedText({required this.es, this.en = ''});

  final String es;
  final String en;

  static const empty = LocalizedText(es: '');

  // Acepta un mapa {es, en}; cualquier otra cosa queda como texto vacío (la
  // validación de la historia lo señala).
  factory LocalizedText.fromJson(Object? json) {
    if (json is! Map) return empty;
    return LocalizedText(
      es: json['es'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  // El texto en el idioma pedido ('es' o 'en'), o el español si falta el inglés.
  String of(String languageCode) =>
      languageCode == 'en' && en.trim().isNotEmpty ? en : es;
}
