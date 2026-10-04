import 'localized_text.dart';

// Una aventura del catálogo (assets/data/catalog.json). Su historia, si ya
// está escrita, está en assets/data/stories/<id>.json.
class Adventure {
  const Adventure({
    required this.id,
    required this.sortOrder,
    required this.difficulty,
    required this.isFree,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final String id;
  final int sortOrder;
  final String difficulty; // easy | medium | hard
  final bool isFree;
  final LocalizedText title;
  final LocalizedText subtitle;
  final LocalizedText description;

  factory Adventure.fromJson(Map<String, dynamic> json) {
    return Adventure(
      id: json['id'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? '',
      isFree: json['isFree'] as bool? ?? false,
      title: LocalizedText.fromJson(json['title']),
      subtitle: LocalizedText.fromJson(json['subtitle']),
      description: LocalizedText.fromJson(json['description']),
    );
  }
}
