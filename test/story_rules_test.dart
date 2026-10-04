import 'package:anunnakitales/logic/story_rules.dart';
import 'package:anunnakitales/models/localized_text.dart';
import 'package:anunnakitales/models/story.dart';
import 'package:flutter_test/flutter_test.dart';

// Un texto de escena válido (50 palabras) en los dos idiomas.
final _sceneText = {
  'es': List.filled(50, 'palabra').join(' '),
  'en': List.filled(50, 'word').join(' '),
};
Map<String, String> _t(String es, [String en = 'text']) => {'es': es, 'en': en};

Map<String, dynamic> _choice(String to, [String? risk]) => {
  'to': to,
  'risk': ?risk,
  'text': _t('Seguir adelante'),
  'description': _t('Una oración que explica la opción.'),
};

Map<String, dynamic> _scene(
  String id, {
  int chapter = 1,
  List<Map<String, dynamic>> choices = const [],
  String? ending,
  Object? text,
}) => {
  'id': id,
  'chapter': chapter,
  'mood': 'epic',
  'text': text ?? _sceneText,
  if (ending != null) 'ending': {'type': ending, 'title': _t('Un final')},
  'choices': choices,
};

// Historia mínima válida:
//   inicio ─low──▶ medio ──▶ fin_mito
//          └high─▶ fin_tragico
Map<String, dynamic> _storyJson({List<Map<String, dynamic>>? scenes}) => {
  'formatVersion': 1,
  'adventureId': 'prueba',
  'hero': {'name': _t('Gilgamesh'), 'description': _t('Rey de Uruk.')},
  'chapters': [
    {'number': 1, 'title': _t('El comienzo')},
    {'number': 2, 'title': _t('El final')},
  ],
  'start': 'inicio',
  'scenes':
      scenes ??
      [
        _scene('inicio', choices: [_choice('medio', 'low'), _choice('fin_tragico', 'high')]),
        _scene('medio', choices: [_choice('fin_mito')]),
        _scene('fin_mito', chapter: 2, ending: 'myth'),
        _scene('fin_tragico', ending: 'tragic'),
      ],
};

Story _story({List<Map<String, dynamic>>? scenes}) =>
    Story.fromJson(_storyJson(scenes: scenes));

void main() {
  group('validateStory', () {
    test('una historia correcta no tiene problemas, ni en modo estricto', () {
      expect(validateStory(_story()), isEmpty);
      expect(validateStory(_story(), strict: true), isEmpty);
    });

    test('detecta un ciclo', () {
      final problems = validateStory(
        _story(
          scenes: [
            _scene('inicio', choices: [_choice('medio', 'low'), _choice('fin_mito', 'high')]),
            _scene('medio', choices: [_choice('inicio')]),
            _scene('fin_mito', ending: 'myth'),
          ],
        ),
      );
      expect(problems, contains(contains('ciclo')));
    });

    test('detecta una opción que apunta a una escena inexistente', () {
      final problems = validateStory(
        _story(
          scenes: [
            _scene('inicio', choices: [_choice('fin_mito', 'low'), _choice('no_existe', 'high')]),
            _scene('fin_mito', ending: 'myth'),
          ],
        ),
      );
      expect(problems, contains(contains('"no_existe", que no existe')));
    });

    test('detecta una escena inalcanzable', () {
      final problems = validateStory(
        _story(
          scenes: [
            _scene('inicio', choices: [_choice('fin_mito')]),
            _scene('suelta', choices: [_choice('fin_mito')]),
            _scene('fin_mito', ending: 'myth'),
          ],
        ),
      );
      expect(problems, ['escena suelta: no se puede alcanzar desde start']);
    });

    test('detecta voseo y vosotros', () {
      final voseo = '${List.filled(45, 'palabra').join(' ')} y vos sabés que podés ganar.';
      final vosotros = '${List.filled(45, 'palabra').join(' ')} y lucháis juntos.';
      final problems = validateStory(
        _story(
          scenes: [
            _scene('inicio', text: _t(voseo), choices: [_choice('medio')]),
            _scene('medio', text: _t(vosotros), choices: [_choice('fin_mito')]),
            _scene('fin_mito', ending: 'myth'),
          ],
        ),
      );
      expect(problems, contains('escena inicio: voseo o vosotros (vos, sabés, podés)'));
      expect(problems, contains('escena medio: voseo o vosotros (lucháis)'));
    });

    test('no confunde el tú ni el futuro con voseo', () {
      expect(
        voseoIn('Tú puedes, tienes y quieres. Lucharás y verás. Después, a través del río.'),
        isEmpty,
      );
    });

    test('detecta textos muy cortos, muy largos o vacíos', () {
      final problems = validateStory(
        _story(
          scenes: [
            _scene('inicio', text: _t('Muy corto.'), choices: [_choice('fin_mito')]),
            _scene('fin_mito', ending: 'myth', text: _t(List.filled(200, 'x').join(' '))),
          ],
        ),
      );
      expect(problems, contains('escena inicio: tiene 2 palabras (mínimo 40)'));
      expect(problems, contains('escena fin_mito: tiene 200 palabras (máximo 190)'));

      final empty = _storyJson();
      (empty['hero'] as Map)['name'] = _t('');
      expect(validateStory(Story.fromJson(empty)), ['hero.name: el texto en español está vacío']);
    });

    test('detecta opciones largas, sin riesgo o con riesgo inválido', () {
      final long = _choice('fin_mito', 'low')
        ..['text'] = _t('uno dos tres cuatro cinco seis siete ocho nueve');
      final problems = validateStory(
        _story(
          scenes: [
            _scene('inicio', choices: [long, _choice('fin_mito'), _choice('fin_mito', 'extremo')]),
            _scene('fin_mito', ending: 'myth'),
          ],
        ),
      );
      expect(problems, contains('escena inicio, opción 1 (texto): tiene 9 palabras (máximo 8)'));
      expect(problems, contains('escena inicio, opción 2: falta risk'));
      expect(problems, contains('escena inicio, opción 3: risk "extremo" no es válido'));
    });

    test('detecta capítulos que bajan, finales con opciones y escenas sin opciones', () {
      final problems = validateStory(
        _story(
          scenes: [
            _scene('inicio', chapter: 2, choices: [_choice('medio')]),
            _scene('medio', chapter: 1),
            _scene('fin_mito', ending: 'myth', choices: [_choice('inicio')]),
          ],
        ),
      );
      expect(problems, contains(contains('baja del capítulo 2 al 1')));
      expect(problems, contains('escena medio: tiene 0 opciones (tienen que ser de 1 a 3)'));
      expect(problems, contains('escena fin_mito: es un final y tiene opciones'));
    });

    test('el modo estricto exige el inglés; el normal no', () {
      final json = _storyJson();
      (json['hero'] as Map)['description'] = _t('Rey de Uruk.', '');
      final story = Story.fromJson(json);
      expect(validateStory(story), isEmpty);
      expect(validateStory(story, strict: true), ['hero.description: falta el texto en inglés']);
    });
  });

  test('nextScene, isEnding y endingsOf', () {
    final story = _story();
    final start = story.scene('inicio')!;
    expect(nextScene(story, start.choices.first)!.id, 'medio');
    expect(isEnding(start), isFalse);
    expect(isEnding(story.scene('fin_mito')!), isTrue);
    expect(endingsOf(story).map((s) => s.id), ['fin_mito', 'fin_tragico']);
  });

  test('shortestPathToMythEnding cuenta las escenas del camino más corto', () {
    expect(shortestPathToMythEnding(_story()), 3);
    final shortcut = _story(
      scenes: [
        _scene('inicio', choices: [_choice('medio', 'low'), _choice('fin_mito', 'high')]),
        _scene('medio', choices: [_choice('fin_mito')]),
        _scene('fin_mito', ending: 'myth'),
      ],
    );
    expect(shortestPathToMythEnding(shortcut), 2);
    final noMyth = _story(scenes: [_scene('inicio', ending: 'tragic')]);
    expect(shortestPathToMythEnding(noMyth), isNull);
  });

  test('canResume solo acepta caminos que existen y no terminan en un final', () {
    final story = _story();
    expect(canResume(story, 'medio', ['inicio', 'medio']), isTrue);
    expect(canResume(story, 'medio', ['inicio', 'borrada', 'medio']), isFalse);
    expect(canResume(story, 'borrada', ['inicio', 'borrada']), isFalse);
    expect(canResume(story, 'medio', ['inicio']), isFalse);
    expect(canResume(story, 'fin_mito', ['inicio', 'medio', 'fin_mito']), isFalse);
    expect(canResume(story, 'inicio', []), isFalse);
  });

  test('pathToLastDecision vuelve a la última escena con más de una opción', () {
    final story = _story();
    expect(pathToLastDecision(story, ['inicio', 'fin_tragico']), ['inicio']);
    // "medio" tiene una sola opción: se salta y vuelve a "inicio".
    expect(pathToLastDecision(story, ['inicio', 'medio', 'fin_mito']), ['inicio']);
    expect(pathToLastDecision(story, ['medio', 'fin_mito']), isNull);
  });

  test('wordCount no cuenta los signos sueltos', () {
    expect(wordCount('—Rey mío — dijo,  el cazador.\n\nTiembla.'), 6);
  });

  test('LocalizedText usa el español si falta el inglés', () {
    const text = LocalizedText(es: 'Hola', en: '');
    expect(text.of('en'), 'Hola');
    expect(text.of('es'), 'Hola');
    expect(const LocalizedText(es: 'Hola', en: 'Hello').of('en'), 'Hello');
  });
}
