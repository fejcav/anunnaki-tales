import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../models/story_scene.dart';
import '../../widgets/stars_background.dart';

// Lo que recibe Gameplay al abrirse: el título de la aventura y la escena.
class GameplayArgs {
  const GameplayArgs({required this.adventureTitle, required this.scene});

  final String adventureTitle;
  final StoryScene scene;
}

// Por ahora solo muestra el texto de la escena. Las opciones, el turno y el
// límite diario llegan en la iteración 5.
class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GameplayArgs;
    return Scaffold(
      appBar: AppBar(title: Text(args.adventureTitle)),
      body: StarsBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(args.scene.narrative, style: AppText.narrative),
        ),
      ),
    );
  }
}
