import '../database.dart';

class UserAchievementsTable extends SupabaseTable<UserAchievementsRow> {
  @override
  String get tableName => 'user_achievements';

  @override
  UserAchievementsRow createRow(Map<String, dynamic> data) =>
      UserAchievementsRow(data);
}

class UserAchievementsRow extends SupabaseDataRow {
  UserAchievementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserAchievementsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get achievementId => getField<String>('achievement_id')!;
  set achievementId(String value) => setField<String>('achievement_id', value);

  DateTime? get unlockedAt => getField<DateTime>('unlocked_at');
  set unlockedAt(DateTime? value) => setField<DateTime>('unlocked_at', value);
}
