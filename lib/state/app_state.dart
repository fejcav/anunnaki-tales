import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../logic/purchase_rules.dart';
import '../logic/story_rules.dart';
import '../models/adventure.dart';
import '../models/local_data.dart';
import '../models/story.dart';
import '../services/story_repository.dart';

// Una aventura del catálogo con su historia (null si todavía no está escrita),
// si está abierta, con candado o "Próximamente", y cuántos finales descubrió.
class AdventureEntry {
  const AdventureEntry({
    required this.adventure,
    required this.story,
    required this.status,
    required this.endingsFound,
  });

  final Adventure adventure;
  final Story? story;
  final AdventureStatus status;
  final int endingsFound;
}

// La partida guardada lista para abrir con "Continuar partida".
class ResumeTarget {
  const ResumeTarget({required this.adventure, required this.story, required this.path});

  final Adventure adventure;
  final Story story;
  final List<String> path;
}

// El estado de la app que leen las pantallas: el catálogo con sus historias,
// los finales descubiertos, la partida guardada y la compra. Tiene los datos
// guardados en memoria; cada cambio se guarda entero en el teléfono y avisa a
// las pantallas.
class AppState extends ChangeNotifier {
  AppState(this._repository, this._store);

  final StoryRepository _repository;
  final LocalStore _store;

  List<Adventure> _catalog = const [];
  final Map<String, Story?> _stories = {};
  LocalData _data = const LocalData();
  bool _catalogFailed = false;

  // Se llama una vez al arrancar: lee lo guardado, el catálogo y las historias.
  Future<void> load() async {
    _data = await _store.load();
    try {
      _catalog = await _repository.loadCatalog();
      for (final a in _catalog) {
        _stories[a.id] = await _repository.loadStory(a.id);
      }
    } catch (error) {
      debugPrint('No se pudo leer el catálogo: $error');
      _catalogFailed = true;
    }
    notifyListeners();
  }

  bool get catalogFailed => _catalogFailed;
  bool get purchased => _data.purchased;

  // Todas las aventuras, en el orden del catálogo, con su estado.
  List<AdventureEntry> get adventures => [
    for (final a in _catalog)
      AdventureEntry(
        adventure: a,
        story: _stories[a.id],
        status: adventureStatus(
          hasStory: _stories[a.id] != null,
          isFree: a.isFree,
          purchased: purchased,
        ),
        endingsFound: _data.endingsOf(a.id).length,
      ),
  ];

  // Cuántas aventuras ya escritas abre la compra (las que no son gratis).
  int get writtenPaidAdventures =>
      _catalog.where((a) => !a.isFree && _stories[a.id] != null).length;

  Story? storyOf(String adventureId) => _stories[adventureId];

  int endingsFoundOf(String adventureId) => _data.endingsOf(adventureId).length;

  // La partida guardada, si su aventura, historia y escena todavía existen.
  ResumeTarget? get resume {
    final game = _data.savedGame;
    if (game == null) return null;
    final story = _stories[game.adventureId];
    final matches = _catalog.where((a) => a.id == game.adventureId);
    if (story == null || matches.isEmpty) return null;
    if (!canResume(story, game.sceneId, game.path)) return null;
    return ResumeTarget(adventure: matches.first, story: story, path: game.path);
  }

  // Guarda la partida en curso (empezar una aventura nueva pisa la anterior).
  Future<void> saveGame(SavedGame game) => _save(_data.withSavedGame(game));

  // Llegó a un final: lo guarda como descubierto y borra la partida.
  Future<void> finishGame(String adventureId, String endingId) =>
      _save(_data.withEndingFound(adventureId, endingId).withSavedGame(null));

  // "Borrar progreso" (Ajustes): borra la partida y los finales; la compra y
  // el idioma quedan.
  Future<void> clearProgress() => _save(_data.withoutProgress());

  // La compra única quedó hecha (comprada o restaurada).
  Future<void> setPurchased() => _save(_data.withPurchased(true));

  // Cambia los datos en memoria antes de guardarlos, así dos cambios seguidos
  // no se pisan.
  Future<void> _save(LocalData next) async {
    _data = next;
    notifyListeners();
    await _store.save(next);
  }
}
