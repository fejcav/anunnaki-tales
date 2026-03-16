import '../database.dart';

class CharactersTable extends SupabaseTable<CharactersRow> {
  @override
  String get tableName => 'characters';

  @override
  CharactersRow createRow(Map<String, dynamic> data) => CharactersRow(data);
}

class CharactersRow extends SupabaseDataRow {
  CharactersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CharactersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String get descriptionEn => getField<String>('description_en')!;
  set descriptionEn(String value) => setField<String>('description_en', value);

  String get descriptionEs => getField<String>('description_es')!;
  set descriptionEs(String value) => setField<String>('description_es', value);

  String get mythologySource => getField<String>('mythology_source')!;
  set mythologySource(String value) =>
      setField<String>('mythology_source', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  String? get domain => getField<String>('domain');
  set domain(String? value) => setField<String>('domain', value);

  String? get portraitUrl => getField<String>('portrait_url');
  set portraitUrl(String? value) => setField<String>('portrait_url', value);

  bool? get isPlayable => getField<bool>('is_playable');
  set isPlayable(bool? value) => setField<bool>('is_playable', value);

  bool? get isPremium => getField<bool>('is_premium');
  set isPremium(bool? value) => setField<bool>('is_premium', value);

  String? get unlockCondition => getField<String>('unlock_condition');
  set unlockCondition(String? value) =>
      setField<String>('unlock_condition', value);

  dynamic get stats => getField<dynamic>('stats');
  set stats(dynamic value) => setField<dynamic>('stats', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
