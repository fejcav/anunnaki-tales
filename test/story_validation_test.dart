import 'dart:convert';
import 'dart:io';

import 'package:anunnakitales/logic/story_rules.dart';
import 'package:anunnakitales/models/story.dart';
import 'package:flutter_test/flutter_test.dart';

// Valida todas las historias de assets/data/stories/ con las reglas de
// docs/formato-historias.md. Si falla, el mensaje dice qué regla y en qué
// escena.
//
// Para el release (modo estricto: el inglés completo), correr:
//   flutter test test/story_validation_test.dart --dart-define=STRICT_STORIES=true
const strict = bool.fromEnvironment('STRICT_STORIES');

void main() {
  final catalog = (jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as List)
      .map((a) => (a as Map)['id'] as String)
      .toSet();
  final files = Directory('assets/data/stories')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('hay al menos una historia', () => expect(files, isNotEmpty));

  for (final file in files) {
    final name = file.uri.pathSegments.last.replaceAll('.json', '');
    test('historia $name${strict ? ' (estricto)' : ''}', () {
      final story = Story.fromJson(
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
      );
      final problems = [
        if (story.adventureId != name)
          'adventureId "${story.adventureId}" no coincide con el nombre del archivo',
        if (!catalog.contains(name)) '"$name" no está en assets/data/catalog.json',
        ...validateStory(story, strict: strict),
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  }
}
