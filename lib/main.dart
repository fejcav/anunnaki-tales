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
import 'screens/paywall/paywall_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/ads.dart';
import 'services/purchases.dart';
import 'services/story_repository.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Solo vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Lo guardado, el catálogo y las historias se leen antes de mostrar nada
  // (son archivos locales: tarda muy poco). La tienda se consulta aparte, sin
  // frenar el arranque: la compra ya quedó guardada en el teléfono.
  final appState = AppState(StoryRepository(), LocalStore());
  await appState.load();
  final purchases = PurchasesService(appState: appState)..start();
  // Anuncios: si el consentimiento ya se resolvió en otra corrida, inicia el
  // SDK sin frenar el arranque. El formulario se pide recién en el Catálogo.
  final ads = AdsService(appState: appState)..start();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: purchases),
        ChangeNotifierProvider.value(value: ads),
      ],
      child: const AnunnakiApp(),
    ),
  );
}

// Nombres de las rutas, para navegar con Navigator.pushNamed(context, Routes.x).
class Routes {
  Routes._();

  static const home = '/';
  static const catalog = '/catalog';
  static const heroIntro = '/hero-intro';
  static const gameplay = '/gameplay';
  static const ending = '/ending';
  static const settings = '/settings';
  static const paywall = '/paywall';
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
    Routes.paywall: (_) => const PaywallScreen(),
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
      routes: _routes,
    );
  }
}
