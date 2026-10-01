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
  String get heroSelectTitle => 'Elige tu héroe';

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
  String homeContinueDetail(String adventure, String hero) {
    return '$adventure · $hero';
  }

  @override
  String get homeGameNotFound => 'Esta partida ya no está disponible';

  @override
  String get homeContinueError =>
      'No pudimos cargar la partida. Revisa tu conexión.';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String catalogTurns(int count) {
    return '~$count turnos';
  }

  @override
  String get catalogError =>
      'No pudimos cargar las aventuras. Revisa tu conexión.';

  @override
  String get catalogEmpty => 'Todavía no hay aventuras disponibles.';

  @override
  String get retry => 'Reintentar';

  @override
  String get heroStart => 'Empezar';

  @override
  String get heroTraveler => 'Viajero';

  @override
  String get heroTravelerDescription =>
      'Un viajero sin nombre que sigue su propio camino.';

  @override
  String get heroPreparing => 'El narrador está preparando tu aventura…';

  @override
  String get heroError => 'No pudimos cargar los héroes. Revisa tu conexión.';

  @override
  String get heroStartError =>
      'No pudimos empezar la aventura. Inténtalo de nuevo.';

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
  String get gameplayThinking => 'El narrador está pensando…';

  @override
  String gameplayFreeChoices(int left, int total) {
    return 'Elecciones gratis hoy: $left de $total';
  }

  @override
  String get gameplayChoiceError =>
      'El narrador no pudo responder. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get historicalFactTitle => 'Dato histórico';

  @override
  String get paywallComingSoon => 'Premium llega pronto';

  @override
  String get back => 'Volver';
}
