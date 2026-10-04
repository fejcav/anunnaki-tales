import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_theme.dart';
import 'config.dart';
import 'data/local_store.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/catalog/catalog_screen.dart';
import 'screens/ending/ending_screen.dart';
import 'screens/gameplay/gameplay_screen.dart';
import 'screens/hero_intro/hero_intro_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/paywall/paywall_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/purchases.dart';
import 'services/story_repository.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Solo vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
  final auth = AuthService();
  final purchases = PurchasesService();
  await purchases.configure();
  final appState = AppState(auth: auth, purchases: purchases)..start();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: auth),
        Provider.value(value: purchases),
        Provider(create: (_) => StoryRepository()),
        Provider(create: (_) => LocalStore()),
        ChangeNotifierProvider.value(value: appState),
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
  static const auth = '/auth';
  static const catalog = '/catalog';
  static const heroIntro = '/hero-intro';
  static const gameplay = '/gameplay';
  static const ending = '/ending';
  static const paywall = '/paywall';
  static const profile = '/profile';
}

class AnunnakiApp extends StatelessWidget {
  const AnunnakiApp({super.key});

  static final Map<String, WidgetBuilder> _routes = {
    Routes.home: (_) => const HomeScreen(),
    Routes.auth: (_) => const AuthScreen(),
    Routes.catalog: (_) => const CatalogScreen(),
    Routes.heroIntro: (_) => const HeroIntroScreen(),
    Routes.gameplay: (_) => const GameplayScreen(),
    Routes.ending: (_) => const EndingScreen(),
    Routes.paywall: (_) => const PaywallScreen(),
    Routes.profile: (_) => const ProfileScreen(),
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
      // Con sesión guardada abre en Inicio; sin sesión, en el ingreso. Se arma
      // una sola ruta inicial para que el ingreso no quede con Inicio debajo.
      onGenerateInitialRoutes: (_) {
        final start = context.read<AuthService>().isSignedIn
            ? Routes.home
            : Routes.auth;
        return [
          MaterialPageRoute(
            settings: RouteSettings(name: start),
            builder: _routes[start]!,
          ),
        ];
      },
      routes: _routes,
    );
  }
}
