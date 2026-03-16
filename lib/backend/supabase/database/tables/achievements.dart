import '../database.dart';

class AchievementsTable extends SupabaseTable<AchievementsRow> {
  @override
  String get tableName => 'achievements';

  @override
  AchievementsRow createRow(Map<String, dynamic> data) => AchievementsRow(data);
}

class AchievementsRow extends SupabaseDataRow {
  AchievementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AchievementsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get nameEn => getField<String>('name_en')!;
  set nameEn(String value) => setField<String>('name_en', value);

  String get nameEs => getField<String>('name_es')!;
  set nameEs(String value) => setField<String>('name_es', value);

  String get descriptionEn => getField<String>('description_en')!;
  set descriptionEn(String value) => setField<String>('description_en', value);

  String get descriptionEs => getField<String>('description_es')!;
  set descriptionEs(String value) => setField<String>('description_es', value);

  String? get iconUrl => getField<String>('icon_url');
  set iconUrl(String? value) => setField<String>('icon_url', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String get conditionType => getField<String>('condition_type')!;
  set conditionType(String value) => setField<String>('condition_type', value);

  dynamic get conditionValue => getField<dynamic>('condition_value')!;
  set conditionValue(dynamic value) =>
      setField<dynamic>('condition_value', value);

  int? get xpReward => getField<int>('xp_reward');
  set xpReward(int? value) => setField<int>('xp_reward', value);

  bool? get isSecret => getField<bool>('is_secret');
  set isSecret(bool? value) => setField<bool>('is_secret', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
