// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Anunnaki Tales';

  @override
  String get homeTitle => 'ANUNNAKI TALES';

  @override
  String get homeSubtitle => 'Mitos Interactivos';

  @override
  String get catalogTitle => 'Elige tu aventura';

  @override
  String get gameplayTitle => 'Aventura';

  @override
  String get homeStart => 'Comenzar aventura';

  @override
  String get homeContinue => 'Continuar partida';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get catalogEmpty => 'Todavía no hay aventuras disponibles.';

  @override
  String get retry => 'Reintentar';

  @override
  String get heroStart => 'Empezar';

  @override
  String get riskLow => 'Riesgo bajo';

  @override
  String get riskMedium => 'Riesgo medio';

  @override
  String get riskHigh => 'Riesgo alto';

  @override
  String gameplayTurn(int turn) {
    return 'Turno $turn';
  }

  @override
  String get historicalFactTitle => 'Dato histórico';

  @override
  String get heroIntroTitle => 'Tu héroe';

  @override
  String get heroIntroAdventure => 'La aventura';

  @override
  String get storyLoadError => 'No pudimos abrir esta historia.';

  @override
  String catalogScenes(int count) {
    return '~$count escenas';
  }

  @override
  String catalogEndings(int found, int total) {
    return 'Finales: $found de $total';
  }

  @override
  String get catalogComingSoon => 'Próximamente';

  @override
  String get catalogError => 'No pudimos cargar las aventuras.';

  @override
  String gameplayChapter(int number, String title) {
    return 'Capítulo $number · $title';
  }

  @override
  String gameplayChapterNumber(int number) {
    return 'Capítulo $number';
  }

  @override
  String get endingTypeMyth => 'Final del mito';

  @override
  String get endingTypeAlternative => 'Final alternativo';

  @override
  String get endingTypeTragic => 'Final trágico';

  @override
  String endingFound(int found, int total) {
    return 'Finales descubiertos: $found de $total';
  }

  @override
  String get endingPlayAgain => 'Volver a jugar';

  @override
  String get endingOtherAdventure => 'Otra aventura';

  @override
  String get endingLastDecision => 'Volver a la última decisión';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsAdPrivacy => 'Privacidad de anuncios';

  @override
  String get settingsLinkError => 'No pudimos abrir el enlace.';

  @override
  String get settingsResetProgress => 'Borrar progreso';

  @override
  String get settingsResetQuestion =>
      'Se borrarán la partida guardada y los finales descubiertos. Esto no se puede deshacer.';

  @override
  String get settingsResetConfirm => 'Borrar';

  @override
  String get settingsResetCancel => 'Cancelar';

  @override
  String get settingsResetDone => 'Progreso borrado';

  @override
  String settingsVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get catalogLocked => 'Bloqueada';

  @override
  String get paywallTitle => 'Desbloquea todos los mitos';

  @override
  String paywallAdventures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aventuras más, ya escritas y listas para jugar',
      one: '1 aventura más, ya escrita y lista para jugar',
    );
    return '$_temp0';
  }

  @override
  String get paywallNoAds => 'Sin anuncios';

  @override
  String get paywallOneTime => 'Pago único, sin suscripción';

  @override
  String get paywallBuy => 'Comprar';

  @override
  String get paywallNotNow => 'Ahora no';

  @override
  String get paywallUnavailable =>
      'La tienda no está disponible ahora. Prueba más tarde.';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get purchaseDone => '¡Listo! Todos los mitos están desbloqueados.';

  @override
  String get purchasePending =>
      'Compra pendiente: se activará cuando la tienda confirme el pago.';

  @override
  String get restoreNotFound => 'No encontramos una compra para restaurar.';

  @override
  String get restoreFailed =>
      'No pudimos conectar con la tienda. Prueba más tarde.';

  @override
  String get settingsUnlockAll => 'Desbloquear todo';

  @override
  String get settingsAllUnlocked => 'Todo desbloqueado';

  @override
  String get back => 'Volver';
}
