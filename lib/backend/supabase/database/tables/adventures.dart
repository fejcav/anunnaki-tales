import '../database.dart';

class AdventuresTable extends SupabaseTable<AdventuresRow> {
  @override
  String get tableName => 'adventures';

  @override
  AdventuresRow createRow(Map<String, dynamic> data) => AdventuresRow(data);
}

class AdventuresRow extends SupabaseDataRow {
  AdventuresRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AdventuresTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get titleEn => getField<String>('title_en')!;
  set titleEn(String value) => setField<String>('title_en', value);

  String get titleEs => getField<String>('title_es')!;
  set titleEs(String value) => setField<String>('title_es', value);

  String? get subtitleEn => getField<String>('subtitle_en');
  set subtitleEn(String? value) => setField<String>('subtitle_en', value);

  String? get subtitleEs => getField<String>('subtitle_es');
  set subtitleEs(String? value) => setField<String>('subtitle_es', value);

  String get descriptionEn => getField<String>('description_en')!;
  set descriptionEn(String value) => setField<String>('description_en', value);

  String get descriptionEs => getField<String>('description_es')!;
  set descriptionEs(String value) => setField<String>('description_es', value);

  String get sourceMyth => getField<String>('source_myth')!;
  set sourceMyth(String value) => setField<String>('source_myth', value);

  String? get historicalPeriod => getField<String>('historical_period');
  set historicalPeriod(String? value) =>
      setField<String>('historical_period', value);

  String? get difficulty => getField<String>('difficulty');
  set difficulty(String? value) => setField<String>('difficulty', value);

  int? get estimatedTurns => getField<int>('estimated_turns');
  set estimatedTurns(int? value) => setField<int>('estimated_turns', value);

  String? get coverImageUrl => getField<String>('cover_image_url');
  set coverImageUrl(String? value) =>
      setField<String>('cover_image_url', value);

  String? get primaryLocation => getField<String>('primary_location');
  set primaryLocation(String? value) =>
      setField<String>('primary_location', value);

  List<String> get tags => getListField<String>('tags');
  set tags(List<String>? value) => setListField<String>('tags', value);

  String? get unlockRequirement => getField<String>('unlock_requirement');
  set unlockRequirement(String? value) =>
      setField<String>('unlock_requirement', value);

  bool? get isFree => getField<bool>('is_free');
  set isFree(bool? value) => setField<bool>('is_free', value);

  bool? get isFeatured => getField<bool>('is_featured');
  set isFeatured(bool? value) => setField<bool>('is_featured', value);

  int? get sortOrder => getField<int>('sort_order');
  set sortOrder(int? value) => setField<int>('sort_order', value);

  dynamic get storyOutline => getField<dynamic>('story_outline');
  set storyOutline(dynamic value) => setField<dynamic>('story_outline', value);

  dynamic get historicalFacts => getField<dynamic>('historical_facts');
  set historicalFacts(dynamic value) =>
      setField<dynamic>('historical_facts', value);

  int? get totalPlays => getField<int>('total_plays');
  set totalPlays(int? value) => setField<int>('total_plays', value);

  double? get avgRating => getField<double>('avg_rating');
  set avgRating(double? value) => setField<double>('avg_rating', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
