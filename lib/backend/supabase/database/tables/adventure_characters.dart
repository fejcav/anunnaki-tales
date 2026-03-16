import '../database.dart';

class AdventureCharactersTable extends SupabaseTable<AdventureCharactersRow> {
  @override
  String get tableName => 'adventure_characters';

  @override
  AdventureCharactersRow createRow(Map<String, dynamic> data) =>
      AdventureCharactersRow(data);
}

class AdventureCharactersRow extends SupabaseDataRow {
  AdventureCharactersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AdventureCharactersTable();

  String get adventureId => getField<String>('adventure_id')!;
  set adventureId(String value) => setField<String>('adventure_id', value);

  String get characterId => getField<String>('character_id')!;
  set characterId(String value) => setField<String>('character_id', value);

  String? get roleInAdventure => getField<String>('role_in_adventure');
  set roleInAdventure(String? value) =>
      setField<String>('role_in_adventure', value);
}
