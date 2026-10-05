import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'data/local_store.dart';
import 'l10n/app_localizations.dart';
import 'screens/catalog/catalog_screen.dart';
import 'screens/ending/ending_screen.dart';
import 'screens/gameplay/gameplay_screen.dart';
import 'screens/hero_intro/hero_intro_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/story_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Solo vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => StoryRepository()),
        Provider(create: (_) => LocalStore()),
      ],
      child: const AnunnakiApp(),
    ),
  );
}

// Avisa a Inicio cuando vuelve a quedar arriba (por ejemplo, al salir de
// Gameplay), para que relea la partida guardada.
final routeObserver = RouteObserver<ModalRoute<void>>();

// Nombres de las rutas, para navegar con Navigator.pushNamed(context, Routes.x).
class Routes {
  Routes._();

  static const home = '/';
  static const catalog = '/catalog';
  static const heroIntro = '/hero-intro';
  static const gameplay = '/gameplay';
  static const ending = '/ending';
  static const settings = '/settings';
}

class AnunnakiApp extends StatelessWidget {
  const AnunnakiApp({super.key});

  static final Map<String, WidgetBuilder> _routes = {
    Routes.home: (_) => const HomeScreen(),
    Routes.catalog: (_) => const CatalogScreen(),
    Routes.heroIntro: (_) => const HeroIntroScreen(),
    Routes.gameplay: (_) => const GameplayScreen(),
    Routes.ending: (_) => const EndingScreen(),
    Routes.settings: (_) => const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [routeObserver],
      routes: _routes,
    );
  }
}
