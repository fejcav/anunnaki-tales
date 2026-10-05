// Todo lo que la app guarda en el teléfono, en una sola clave de
// shared_preferences (ver "Datos en shared_preferences" en CLAUDE.md).
class LocalData {
  const LocalData({this.language, this.savedGame, this.endingsFound = const {}});

  static const schemaVersion = 2;

  final String? language; // null = el del teléfono
  final SavedGame? savedGame;
  final Map<String, List<String>> endingsFound; // aventura → ids de finales

  // Los finales que ya descubrió en una aventura.
  List<String> endingsOf(String adventureId) => endingsFound[adventureId] ?? const [];

  // Copia con otra partida guardada (null = sin partida).
  LocalData withSavedGame(SavedGame? savedGame) {
    return LocalData(language: language, savedGame: savedGame, endingsFound: endingsFound);
  }

  // Copia con un final más descubierto (si ya estaba, no se repite).
  LocalData withEndingFound(String adventureId, String endingId) {
    final found = endingsOf(adventureId);
    if (found.contains(endingId)) return this;
    return LocalData(
      language: language,
      savedGame: savedGame,
      endingsFound: {...endingsFound, adventureId: [...found, endingId]},
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'language': language,
    'savedGame': savedGame?.toJson(),
    'endingsFound': endingsFound,
  };

  // Un JSON de la versión 1 (partidas del servidor viejo y contador de elecciones)
  // se descarta salvo el idioma.
  factory LocalData.fromJson(Map<String, dynamic> json) {
    final language = json['language'] as String?;
    if (json['schemaVersion'] != schemaVersion) return LocalData(language: language);
    final game = json['savedGame'];
    final endings = json['endingsFound'] as Map? ?? const {};
    return LocalData(
      language: language,
      savedGame: game == null
          ? null
          : SavedGame.fromJson(Map<String, dynamic>.from(game as Map)),
      endingsFound: {
        for (final e in endings.entries)
          e.key as String: (e.value as List).cast<String>().toList(),
      },
    );
  }
}

// La partida en curso, para "Continuar partida": la aventura, la escena
// actual y el camino (ids de las escenas vistas, la actual al final).
class SavedGame {
  const SavedGame({required this.adventureId, required this.sceneId, required this.path});

  final String adventureId;
  final String sceneId;
  final List<String> path;

  Map<String, dynamic> toJson() => {
    'adventureId': adventureId,
    'sceneId': sceneId,
    'path': path,
  };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    return SavedGame(
      adventureId: json['adventureId'] as String,
      sceneId: json['sceneId'] as String,
      path: (json['path'] as List).cast<String>().toList(),
    );
  }
}
