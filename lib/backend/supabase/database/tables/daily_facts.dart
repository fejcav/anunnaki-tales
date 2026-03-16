import '../database.dart';

class DailyFactsTable extends SupabaseTable<DailyFactsRow> {
  @override
  String get tableName => 'daily_facts';

  @override
  DailyFactsRow createRow(Map<String, dynamic> data) => DailyFactsRow(data);
}

class DailyFactsRow extends SupabaseDataRow {
  DailyFactsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DailyFactsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get factEn => getField<String>('fact_en')!;
  set factEn(String value) => setField<String>('fact_en', value);

  String get factEs => getField<String>('fact_es')!;
  set factEs(String value) => setField<String>('fact_es', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  String? get relatedAdventureId => getField<String>('related_adventure_id');
  set relatedAdventureId(String? value) =>
      setField<String>('related_adventure_id', value);

  String? get relatedCharacterId => getField<String>('related_character_id');
  set relatedCharacterId(String? value) =>
      setField<String>('related_character_id', value);

  DateTime? get scheduledDate => getField<DateTime>('scheduled_date');
  set scheduledDate(DateTime? value) =>
      setField<DateTime>('scheduled_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
