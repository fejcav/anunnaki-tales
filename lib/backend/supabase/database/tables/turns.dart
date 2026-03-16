import '../database.dart';

class TurnsTable extends SupabaseTable<TurnsRow> {
  @override
  String get tableName => 'turns';

  @override
  TurnsRow createRow(Map<String, dynamic> data) => TurnsRow(data);
}

class TurnsRow extends SupabaseDataRow {
  TurnsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TurnsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get sessionId => getField<String>('session_id')!;
  set sessionId(String value) => setField<String>('session_id', value);

  int get turnNumber => getField<int>('turn_number')!;
  set turnNumber(int value) => setField<int>('turn_number', value);

  String get narrative => getField<String>('narrative')!;
  set narrative(String value) => setField<String>('narrative', value);

  String? get sceneMood => getField<String>('scene_mood');
  set sceneMood(String? value) => setField<String>('scene_mood', value);

  dynamic get choices => getField<dynamic>('choices')!;
  set choices(dynamic value) => setField<dynamic>('choices', value);

  int? get chosenOption => getField<int>('chosen_option');
  set chosenOption(int? value) => setField<int>('chosen_option', value);

  String? get historicalFact => getField<String>('historical_fact');
  set historicalFact(String? value) =>
      setField<String>('historical_fact', value);

  dynamic get characterStateAfter =>
      getField<dynamic>('character_state_after');
  set characterStateAfter(dynamic value) =>
      setField<dynamic>('character_state_after', value);

  int? get aiTokensUsed => getField<int>('ai_tokens_used');
  set aiTokensUsed(int? value) => setField<int>('ai_tokens_used', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
