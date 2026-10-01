// Todo lo que la app guarda en el teléfono, en una sola clave de
// shared_preferences (ver "Datos en shared_preferences" en CLAUDE.md).
class LocalData {
  const LocalData({
    this.dailyChoicesUsed = 0,
    this.lastChoiceDay,
    this.language,
    this.savedGame,
  });

  static const schemaVersion = 1;

  final int dailyChoicesUsed;
  final String? lastChoiceDay; // yyyy-MM-dd local
  final String? language; // null = el del teléfono
  final SavedGame? savedGame;

  // Copia con otra partida guardada (null = sin partida).
  LocalData withSavedGame(SavedGame? savedGame) {
    return LocalData(
      dailyChoicesUsed: dailyChoicesUsed,
      lastChoiceDay: lastChoiceDay,
      language: language,
      savedGame: savedGame,
    );
  }

  // Copia con otro contador de elecciones del día.
  LocalData withDailyChoices({required int used, required String day}) {
    return LocalData(
      dailyChoicesUsed: used,
      lastChoiceDay: day,
      language: language,
      savedGame: savedGame,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'dailyChoicesUsed': dailyChoicesUsed,
    'lastChoiceDay': lastChoiceDay,
    'language': language,
    'savedGame': savedGame?.toJson(),
  };

  factory LocalData.fromJson(Map<String, dynamic> json) {
    final game = json['savedGame'];
    return LocalData(
      dailyChoicesUsed: (json['dailyChoicesUsed'] as num?)?.toInt() ?? 0,
      lastChoiceDay: json['lastChoiceDay'] as String?,
      language: json['language'] as String?,
      savedGame: game == null
          ? null
          : SavedGame.fromJson(Map<String, dynamic>.from(game as Map)),
    );
  }
}

// La última partida empezada, para "Continuar partida". Es de un usuario: si
// entra otro, no se le muestra.
class SavedGame {
  const SavedGame({
    required this.userId,
    required this.sessionId,
    required this.adventureId,
    required this.mythId,
    required this.adventureTitle,
    required this.heroName,
  });

  final String userId;
  final String sessionId;
  final String adventureId;
  final String mythId;
  final String adventureTitle;
  final String heroName;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'sessionId': sessionId,
    'adventureId': adventureId,
    'mythId': mythId,
    'adventureTitle': adventureTitle,
    'heroName': heroName,
  };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    return SavedGame(
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      adventureId: json['adventureId'] as String,
      mythId: json['mythId'] as String,
      adventureTitle: json['adventureTitle'] as String,
      heroName: json['heroName'] as String,
    );
  }
}
