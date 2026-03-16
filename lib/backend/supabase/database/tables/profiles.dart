import '../database.dart';

class ProfilesTable extends SupabaseTable<ProfilesRow> {
  @override
  String get tableName => 'profiles';

  @override
  ProfilesRow createRow(Map<String, dynamic> data) => ProfilesRow(data);
}

class ProfilesRow extends SupabaseDataRow {
  ProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfilesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get displayName => getField<String>('display_name')!;
  set displayName(String value) => setField<String>('display_name', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  String? get preferredLanguage => getField<String>('preferred_language');
  set preferredLanguage(String? value) =>
      setField<String>('preferred_language', value);

  String? get subscriptionTier => getField<String>('subscription_tier');
  set subscriptionTier(String? value) =>
      setField<String>('subscription_tier', value);

  DateTime? get subscriptionExpiresAt =>
      getField<DateTime>('subscription_expires_at');
  set subscriptionExpiresAt(DateTime? value) =>
      setField<DateTime>('subscription_expires_at', value);

  int? get totalAdventuresCompleted =>
      getField<int>('total_adventures_completed');
  set totalAdventuresCompleted(int? value) =>
      setField<int>('total_adventures_completed', value);

  int? get totalChoicesMade => getField<int>('total_choices_made');
  set totalChoicesMade(int? value) =>
      setField<int>('total_choices_made', value);

  int? get totalPlayTimeMinutes => getField<int>('total_play_time_minutes');
  set totalPlayTimeMinutes(int? value) =>
      setField<int>('total_play_time_minutes', value);

  int? get dailyChoicesRemaining => getField<int>('daily_choices_remaining');
  set dailyChoicesRemaining(int? value) =>
      setField<int>('daily_choices_remaining', value);

  DateTime? get dailyChoicesResetAt =>
      getField<DateTime>('daily_choices_reset_at');
  set dailyChoicesResetAt(DateTime? value) =>
      setField<DateTime>('daily_choices_reset_at', value);

  int? get streakDays => getField<int>('streak_days');
  set streakDays(int? value) => setField<int>('streak_days', value);

  DateTime? get lastPlayedAt => getField<DateTime>('last_played_at');
  set lastPlayedAt(DateTime? value) =>
      setField<DateTime>('last_played_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
