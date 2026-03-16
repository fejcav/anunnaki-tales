import '../database.dart';

class GameSessionsTable extends SupabaseTable<GameSessionsRow> {
  @override
  String get tableName => 'game_sessions';

  @override
  GameSessionsRow createRow(Map<String, dynamic> data) => GameSessionsRow(data);
}

class GameSessionsRow extends SupabaseDataRow {
  GameSessionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GameSessionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get adventureId => getField<String>('adventure_id')!;
  set adventureId(String value) => setField<String>('adventure_id', value);

  String? get characterId => getField<String>('character_id');
  set characterId(String? value) => setField<String>('character_id', value);

  String? get playerName => getField<String>('player_name');
  set playerName(String? value) => setField<String>('player_name', value);

  String? get difficulty => getField<String>('difficulty');
  set difficulty(String? value) => setField<String>('difficulty', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  int? get currentTurn => getField<int>('current_turn');
  set currentTurn(int? value) => setField<int>('current_turn', value);

  int? get storyProgress => getField<int>('story_progress');
  set storyProgress(int? value) => setField<int>('story_progress', value);

  dynamic get characterState => getField<dynamic>('character_state');
  set characterState(dynamic value) =>
      setField<dynamic>('character_state', value);

  String? get endingType => getField<String>('ending_type');
  set endingType(String? value) => setField<String>('ending_type', value);

  int? get rating => getField<int>('rating');
  set rating(int? value) => setField<int>('rating', value);

  DateTime? get startedAt => getField<DateTime>('started_at');
  set startedAt(DateTime? value) => setField<DateTime>('started_at', value);

  DateTime? get lastPlayedAt => getField<DateTime>('last_played_at');
  set lastPlayedAt(DateTime? value) =>
      setField<DateTime>('last_played_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);
}
