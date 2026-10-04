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
  String get paywallTitle => 'Premium';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get authTabSignIn => 'Ingresar';

  @override
  String get authTabSignUp => 'Crear cuenta';

  @override
  String get authEmail => 'Correo';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authRepeatPassword => 'Repetir contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authEmailInvalid => 'Escribe un correo válido';

  @override
  String authPasswordTooShort(int min) {
    return 'La contraseña debe tener al menos $min caracteres';
  }

  @override
  String get authPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get authErrorInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get authErrorEmailTaken => 'Ese correo ya tiene cuenta';

  @override
  String get authErrorWeakPassword =>
      'Esa contraseña es muy débil. Prueba con otra más larga.';

  @override
  String get authErrorSamePassword =>
      'La contraseña nueva debe ser distinta de la anterior';

  @override
  String get authErrorInvalidCode => 'El código no es correcto o ya venció';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos. Espera un rato y vuelve a intentarlo.';

  @override
  String get authErrorNoConnection => 'Sin conexión';

  @override
  String get authErrorUnknown => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get resetTitle => 'Cambiar contraseña';

  @override
  String get resetEmailIntro =>
      'Escribe tu correo y te enviaremos un código para cambiar la contraseña.';

  @override
  String get resetSendCode => 'Enviar código';

  @override
  String resetCodeIntro(String email) {
    return 'Te enviamos un código a $email. Puede tardar unos minutos; revisa también la carpeta de correo no deseado.';
  }

  @override
  String get resetCode => 'Código';

  @override
  String get resetCodeInvalid => 'El código tiene entre 6 y 10 números';

  @override
  String get resetNewPassword => 'Contraseña nueva';

  @override
  String get resetConfirm => 'Cambiar contraseña';

  @override
  String get resetDone => 'Contraseña cambiada';

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
  String get paywallHeadline => 'Desbloquea el poder de los dioses';

  @override
  String get paywallBenefitUnlimited => 'Elecciones ilimitadas cada día';

  @override
  String get paywallBenefitNoAds => 'Sin anuncios';

  @override
  String get paywallMonthly => 'Mensual';

  @override
  String get paywallAnnual => 'Anual';

  @override
  String paywallPerMonth(String price) {
    return '$price / mes';
  }

  @override
  String paywallPerYear(String price) {
    return '$price / año';
  }

  @override
  String get paywallPopular => 'Más popular';

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallContinueFree => 'Continuar gratis';

  @override
  String get paywallLegal =>
      'La suscripción se renueva automáticamente al final de cada período, al mismo precio, salvo que la canceles al menos 24 horas antes desde Google Play o App Store. El cobro se hace en tu cuenta de la tienda al confirmar la compra.';

  @override
  String get paywallLoadError =>
      'No pudimos cargar los planes. Revisa tu conexión.';

  @override
  String get paywallBuyError =>
      'No pudimos completar la compra. Inténtalo de nuevo.';

  @override
  String get restoreDone => 'Listo: Premium activo';

  @override
  String get restoreNotFound => 'No encontramos compras para restaurar.';

  @override
  String get restoreError =>
      'No pudimos restaurar las compras. Revisa tu conexión.';

  @override
  String get profilePremium => 'Suscripción';

  @override
  String get profilePremiumActive => 'Premium activo';

  @override
  String get profileGetPremium => 'Hazte Premium';

  @override
  String get profileRestore => 'Restaurar compras';

  @override
  String get profileEmail => 'Correo';

  @override
  String get profilePrivacyPolicy => 'Política de privacidad';

  @override
  String get profileLinkError => 'No pudimos abrir el enlace.';

  @override
  String profileVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileDeleteTitle => '¿Eliminar tu cuenta?';

  @override
  String get profileDeleteBody =>
      'Se borrarán para siempre tu perfil, tus partidas y tu progreso. Esta acción no se puede deshacer. Si tienes Premium, cancela la suscripción desde Google Play o App Store: eliminar la cuenta no la cancela.';

  @override
  String get profileDeleteCancel => 'Cancelar';

  @override
  String get profileDeleteConfirm => 'Eliminar';

  @override
  String get profileDeleteError =>
      'No pudimos eliminar tu cuenta. Inténtalo de nuevo o escríbenos a fejcavallo@gmail.com';

  @override
  String get back => 'Volver';
}
