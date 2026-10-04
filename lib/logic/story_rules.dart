import '../models/localized_text.dart';
import '../models/story.dart';
import '../models/story_scene.dart';

// Reglas de las historias escritas de antemano (ver docs/formato-historias.md).
// Todo son funciones puras: reciben la historia y devuelven datos.

const validMoods = {
  'epic',
  'mysterious',
  'dangerous',
  'peaceful',
  'sacred',
  'tragic',
  'triumphant',
};
const validRisks = {'low', 'medium', 'high'};
const validEndingTypes = {'myth', 'alternative', 'tragic'};

// Límites de largo (en palabras) de los textos en español.
const sceneMinWords = 40;
const sceneMaxWords = 190;
const choiceMaxWords = 8;
const factMaxWords = 50;

// Formas de voseo y de vosotros que no pueden aparecer (los textos van en
// español neutro, con tú). Además, cualquier palabra terminada en -áis o -éis
// (lucháis, tenéis) se toma como vosotros. Quedan afuera las formas que
// también existen con tú o con yo (ves, salí, elegí…).
const _forbiddenWords = {
  'vos', 'sos', 'vosotros', 'vosotras', 'os', 'sois',
  'tenés', 'podés', 'querés', 'sabés', 'hacés', 'ponés', 'sentís', 'decís',
  'venís', 'vivís', 'pedís', 'salís', 'elegís', 'seguís', 'oís', 'conocés',
  'creés', 'debés', 'comés', 'corrés', 'volvés', 'entendés',
  'luchás', 'mirás', 'buscás', 'llegás', 'hablás', 'pensás', 'necesitás',
  'esperás', 'encontrás', 'recordás', 'dejás', 'llevás', 'caminás',
  'mirá', 'vení', 'decí', 'hacé', 'tené', 'poné', 'andá', 'escuchá',
  'dejá', 'pensá', 'esperá', 'fijate', 'acordate',
  'andate', 'sentate', 'quedate', 'calmate', 'callate',
};
final _vosotrosEnding = RegExp(r'(áis|éis)$');
final _idPattern = RegExp(r'^[a-z0-9_]+$');
final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);
final _letters = RegExp(r'[\p{L}]+', unicode: true);

// Cantidad de palabras de un texto (los signos sueltos, como "—", no cuentan).
int wordCount(String text) =>
    text.split(RegExp(r'\s+')).where((w) => _wordChar.hasMatch(w)).length;

// Las formas de voseo o de vosotros que aparecen en un texto (en minúsculas).
List<String> voseoIn(String text) {
  return _letters
      .allMatches(text.toLowerCase())
      .map((m) => m.group(0)!)
      .where((w) => _forbiddenWords.contains(w) || _vosotrosEnding.hasMatch(w))
      .toSet()
      .toList();
}

// La escena a la que lleva una opción, o null si no existe.
StoryScene? nextScene(Story story, StoryChoice choice) => story.scene(choice.to);

// Si la escena es un final.
bool isEnding(StoryScene scene) => scene.ending != null;

// Todos los finales de la historia, en el orden del archivo.
List<StoryScene> endingsOf(Story story) =>
    story.scenes.where(isEnding).toList();

// Cantidad de escenas (contando la primera y el final) del camino más corto
// desde el inicio hasta el final del mito. Null si no hay final del mito o
// no se llega a él.
int? shortestPathToMythEnding(Story story) {
  if (story.scene(story.start) == null) return null;
  final depth = {story.start: 1};
  final queue = [story.start];
  for (var i = 0; i < queue.length; i++) {
    final scene = story.scene(queue[i]);
    if (scene == null) continue;
    if (scene.ending?.type == 'myth') return depth[scene.id];
    for (final choice in scene.choices) {
      if (depth.containsKey(choice.to)) continue;
      depth[choice.to] = depth[scene.id]! + 1;
      queue.add(choice.to);
    }
  }
  return null;
}

// Si una partida guardada se puede continuar: el camino no está vacío, todas
// sus escenas existen, la última es `sceneId` y no es un final.
bool canResume(Story story, String sceneId, List<String> path) {
  if (path.isEmpty || path.last != sceneId) return false;
  if (path.any((id) => story.scene(id) == null)) return false;
  return !isEnding(story.scene(sceneId)!);
}

// "Volver a la última decisión": el camino recortado hasta la última escena
// (antes del final) que tiene más de una opción. Null si no hay ninguna.
List<String>? pathToLastDecision(Story story, List<String> path) {
  for (var i = path.length - 2; i >= 0; i--) {
    final scene = story.scene(path[i]);
    if (scene != null && scene.choices.length > 1) return path.sublist(0, i + 1);
  }
  return null;
}

// Revisa una historia con todas las reglas de docs/formato-historias.md y
// devuelve la lista de problemas (vacía si está bien). `strict` (para el
// release) además exige que ningún texto en inglés esté vacío.
List<String> validateStory(Story story, {bool strict = false}) {
  final problems = <String>[];

  if (story.formatVersion != 1) {
    problems.add('formatVersion es ${story.formatVersion}; tiene que ser 1');
  }
  if (story.adventureId.isEmpty) problems.add('falta adventureId');

  // Textos: ninguno en español vacío, sin voseo; en estricto, ninguno en
  // inglés vacío.
  void checkText(String where, LocalizedText text, {int? minWords, int? maxWords}) {
    final es = text.es.trim();
    if (es.isEmpty) {
      problems.add('$where: el texto en español está vacío');
    } else {
      final words = wordCount(es);
      if (minWords != null && words < minWords) {
        problems.add('$where: tiene $words palabras (mínimo $minWords)');
      }
      if (maxWords != null && words > maxWords) {
        problems.add('$where: tiene $words palabras (máximo $maxWords)');
      }
      final voseo = voseoIn(es);
      if (voseo.isNotEmpty) {
        problems.add('$where: voseo o vosotros (${voseo.join(', ')})');
      }
    }
    if (strict && text.en.trim().isEmpty) {
      problems.add('$where: falta el texto en inglés');
    }
  }

  checkText('hero.name', story.heroName);
  checkText('hero.description', story.heroDescription);
  story.chapters.forEach((number, title) => checkText('capítulo $number', title));

  // Ids únicos y con formato válido.
  final seen = <String>{};
  for (final scene in story.scenes) {
    if (!_idPattern.hasMatch(scene.id)) {
      problems.add('escena "${scene.id}": el id solo puede tener minúsculas, números y _');
    }
    if (!seen.add(scene.id)) problems.add('escena "${scene.id}": id repetido');
  }

  // Regla 1: start y todos los `to` existen.
  if (story.scene(story.start) == null) {
    problems.add('start "${story.start}" no existe');
  }

  for (final scene in story.scenes) {
    final where = 'escena ${scene.id}';

    // Regla 5: valores válidos.
    if (!validMoods.contains(scene.mood)) {
      problems.add('$where: mood "${scene.mood}" no es válido');
    }

    // Regla 3: opciones y finales.
    final ending = scene.ending;
    if (ending != null) {
      if (scene.choices.isNotEmpty) problems.add('$where: es un final y tiene opciones');
      if (!validEndingTypes.contains(ending.type)) {
        problems.add('$where: ending.type "${ending.type}" no es válido');
      }
      checkText('$where (título del final)', ending.title);
    } else if (scene.choices.isEmpty || scene.choices.length > 3) {
      problems.add('$where: tiene ${scene.choices.length} opciones (tienen que ser de 1 a 3)');
    }

    // Regla 6: largos de los textos.
    checkText(where, scene.text, minWords: sceneMinWords, maxWords: sceneMaxWords);
    final fact = scene.fact;
    if (fact != null) checkText('$where (dato histórico)', fact, maxWords: factMaxWords);

    for (final (i, choice) in scene.choices.indexed) {
      final whereChoice = '$where, opción ${i + 1}';
      final target = story.scene(choice.to);
      if (target == null) {
        problems.add('$whereChoice: lleva a "${choice.to}", que no existe');
      } else if (target.chapter < scene.chapter) {
        // Regla 4: el capítulo nunca baja.
        problems.add(
          '$whereChoice: baja del capítulo ${scene.chapter} al ${target.chapter} (${target.id})',
        );
      }
      final risk = choice.risk;
      if (risk == null) {
        if (scene.choices.length > 1) problems.add('$whereChoice: falta risk');
      } else if (!validRisks.contains(risk)) {
        problems.add('$whereChoice: risk "$risk" no es válido');
      }
      checkText('$whereChoice (texto)', choice.text, maxWords: choiceMaxWords);
      checkText('$whereChoice (descripción)', choice.description);
    }
  }

  // Regla 2: todas las escenas se alcanzan desde start y no hay ciclos.
  // Recorrido en profundidad: una escena "en curso" que vuelve a aparecer es
  // un ciclo.
  final reached = <String>{};
  final inProgress = <String>{};
  final cycles = <String>{};
  void visit(String id) {
    final scene = story.scene(id);
    if (scene == null) return;
    if (inProgress.contains(id)) {
      cycles.add(id);
      return;
    }
    if (!reached.add(id)) return;
    inProgress.add(id);
    for (final choice in scene.choices) {
      visit(choice.to);
    }
    inProgress.remove(id);
  }

  visit(story.start);
  for (final id in cycles) {
    problems.add('escena $id: forma parte de un ciclo (una opción vuelve atrás)');
  }
  for (final scene in story.scenes) {
    if (!reached.contains(scene.id)) {
      problems.add('escena ${scene.id}: no se puede alcanzar desde start');
    }
  }

  if (endingsOf(story).isEmpty) problems.add('la historia no tiene ningún final');
  if (!story.scenes.any((s) => s.ending?.type == 'myth')) {
    problems.add('la historia no tiene final del mito (ending.type "myth")');
  }

  return problems;
}
