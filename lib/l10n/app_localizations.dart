import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Anunnaki Tales'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'ANUNNAKI TALES'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mitos Interactivos'**
  String get homeSubtitle;

  /// No description provided for @catalogTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tu aventura'**
  String get catalogTitle;

  /// No description provided for @gameplayTitle.
  ///
  /// In es, this message translates to:
  /// **'Aventura'**
  String get gameplayTitle;

  /// No description provided for @paywallTitle.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get paywallTitle;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @authTabSignIn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get authTabSignIn;

  /// No description provided for @authTabSignUp.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authTabSignUp;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPassword;

  /// No description provided for @authRepeatPassword.
  ///
  /// In es, this message translates to:
  /// **'Repetir contraseña'**
  String get authRepeatPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPassword;

  /// No description provided for @authEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un correo válido'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {min} caracteres'**
  String authPasswordTooShort(int min);

  /// No description provided for @authPasswordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPasswordsDontMatch;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailTaken.
  ///
  /// In es, this message translates to:
  /// **'Ese correo ya tiene cuenta'**
  String get authErrorEmailTaken;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'Esa contraseña es muy débil. Prueba con otra más larga.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorSamePassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña nueva debe ser distinta de la anterior'**
  String get authErrorSamePassword;

  /// No description provided for @authErrorInvalidCode.
  ///
  /// In es, this message translates to:
  /// **'El código no es correcto o ya venció'**
  String get authErrorInvalidCode;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera un rato y vuelve a intentarlo.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNoConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get authErrorNoConnection;

  /// No description provided for @authErrorUnknown.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Inténtalo de nuevo.'**
  String get authErrorUnknown;

  /// No description provided for @resetTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get resetTitle;

  /// No description provided for @resetEmailIntro.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y te enviaremos un código para cambiar la contraseña.'**
  String get resetEmailIntro;

  /// No description provided for @resetSendCode.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get resetSendCode;

  /// No description provided for @resetCodeIntro.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un código a {email}. Puede tardar unos minutos; revisa también la carpeta de correo no deseado.'**
  String resetCodeIntro(String email);

  /// No description provided for @resetCode.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get resetCode;

  /// No description provided for @resetCodeInvalid.
  ///
  /// In es, this message translates to:
  /// **'El código tiene entre 6 y 10 números'**
  String get resetCodeInvalid;

  /// No description provided for @resetNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get resetNewPassword;

  /// No description provided for @resetConfirm.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get resetConfirm;

  /// No description provided for @resetDone.
  ///
  /// In es, this message translates to:
  /// **'Contraseña cambiada'**
  String get resetDone;

  /// No description provided for @homeStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar aventura'**
  String get homeStart;

  /// No description provided for @homeContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar partida'**
  String get homeContinue;

  /// No description provided for @difficultyEasy.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get difficultyHard;

  /// No description provided for @catalogEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay aventuras disponibles.'**
  String get catalogEmpty;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @heroStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get heroStart;

  /// No description provided for @riskLow.
  ///
  /// In es, this message translates to:
  /// **'Riesgo bajo'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In es, this message translates to:
  /// **'Riesgo medio'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In es, this message translates to:
  /// **'Riesgo alto'**
  String get riskHigh;

  /// No description provided for @gameplayTurn.
  ///
  /// In es, this message translates to:
  /// **'Turno {turn}'**
  String gameplayTurn(int turn);

  /// No description provided for @historicalFactTitle.
  ///
  /// In es, this message translates to:
  /// **'Dato histórico'**
  String get historicalFactTitle;

  /// No description provided for @heroIntroTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu héroe'**
  String get heroIntroTitle;

  /// No description provided for @heroIntroAdventure.
  ///
  /// In es, this message translates to:
  /// **'La aventura'**
  String get heroIntroAdventure;

  /// No description provided for @storyLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esta historia.'**
  String get storyLoadError;

  /// No description provided for @catalogScenes.
  ///
  /// In es, this message translates to:
  /// **'~{count} escenas'**
  String catalogScenes(int count);

  /// No description provided for @catalogEndings.
  ///
  /// In es, this message translates to:
  /// **'Finales: {found} de {total}'**
  String catalogEndings(int found, int total);

  /// No description provided for @catalogComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get catalogComingSoon;

  /// No description provided for @catalogError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las aventuras.'**
  String get catalogError;

  /// No description provided for @gameplayChapter.
  ///
  /// In es, this message translates to:
  /// **'Capítulo {number} · {title}'**
  String gameplayChapter(int number, String title);

  /// No description provided for @gameplayChapterNumber.
  ///
  /// In es, this message translates to:
  /// **'Capítulo {number}'**
  String gameplayChapterNumber(int number);

  /// No description provided for @endingTypeMyth.
  ///
  /// In es, this message translates to:
  /// **'Final del mito'**
  String get endingTypeMyth;

  /// No description provided for @endingTypeAlternative.
  ///
  /// In es, this message translates to:
  /// **'Final alternativo'**
  String get endingTypeAlternative;

  /// No description provided for @endingTypeTragic.
  ///
  /// In es, this message translates to:
  /// **'Final trágico'**
  String get endingTypeTragic;

  /// No description provided for @endingFound.
  ///
  /// In es, this message translates to:
  /// **'Finales descubiertos: {found} de {total}'**
  String endingFound(int found, int total);

  /// No description provided for @endingPlayAgain.
  ///
  /// In es, this message translates to:
  /// **'Volver a jugar'**
  String get endingPlayAgain;

  /// No description provided for @endingOtherAdventure.
  ///
  /// In es, this message translates to:
  /// **'Otra aventura'**
  String get endingOtherAdventure;

  /// No description provided for @endingLastDecision.
  ///
  /// In es, this message translates to:
  /// **'Volver a la última decisión'**
  String get endingLastDecision;

  /// No description provided for @paywallHeadline.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea el poder de los dioses'**
  String get paywallHeadline;

  /// No description provided for @paywallBenefitUnlimited.
  ///
  /// In es, this message translates to:
  /// **'Elecciones ilimitadas cada día'**
  String get paywallBenefitUnlimited;

  /// No description provided for @paywallBenefitNoAds.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios'**
  String get paywallBenefitNoAds;

  /// No description provided for @paywallMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get paywallMonthly;

  /// No description provided for @paywallAnnual.
  ///
  /// In es, this message translates to:
  /// **'Anual'**
  String get paywallAnnual;

  /// No description provided for @paywallPerMonth.
  ///
  /// In es, this message translates to:
  /// **'{price} / mes'**
  String paywallPerMonth(String price);

  /// No description provided for @paywallPerYear.
  ///
  /// In es, this message translates to:
  /// **'{price} / año'**
  String paywallPerYear(String price);

  /// No description provided for @paywallPopular.
  ///
  /// In es, this message translates to:
  /// **'Más popular'**
  String get paywallPopular;

  /// No description provided for @paywallRestore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compra'**
  String get paywallRestore;

  /// No description provided for @paywallContinueFree.
  ///
  /// In es, this message translates to:
  /// **'Continuar gratis'**
  String get paywallContinueFree;

  /// No description provided for @paywallLegal.
  ///
  /// In es, this message translates to:
  /// **'La suscripción se renueva automáticamente al final de cada período, al mismo precio, salvo que la canceles al menos 24 horas antes desde Google Play o App Store. El cobro se hace en tu cuenta de la tienda al confirmar la compra.'**
  String get paywallLegal;

  /// No description provided for @paywallLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los planes. Revisa tu conexión.'**
  String get paywallLoadError;

  /// No description provided for @paywallBuyError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la compra. Inténtalo de nuevo.'**
  String get paywallBuyError;

  /// No description provided for @restoreDone.
  ///
  /// In es, this message translates to:
  /// **'Listo: Premium activo'**
  String get restoreDone;

  /// No description provided for @restoreNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos compras para restaurar.'**
  String get restoreNotFound;

  /// No description provided for @restoreError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos restaurar las compras. Revisa tu conexión.'**
  String get restoreError;

  /// No description provided for @profilePremium.
  ///
  /// In es, this message translates to:
  /// **'Suscripción'**
  String get profilePremium;

  /// No description provided for @profilePremiumActive.
  ///
  /// In es, this message translates to:
  /// **'Premium activo'**
  String get profilePremiumActive;

  /// No description provided for @profileGetPremium.
  ///
  /// In es, this message translates to:
  /// **'Hazte Premium'**
  String get profileGetPremium;

  /// No description provided for @profileRestore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compras'**
  String get profileRestore;

  /// No description provided for @profileEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get profileEmail;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileLinkError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el enlace.'**
  String get profileLinkError;

  /// No description provided for @profileVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} ({build})'**
  String profileVersion(String version, String build);

  /// No description provided for @profileSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar tu cuenta?'**
  String get profileDeleteTitle;

  /// No description provided for @profileDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán para siempre tu perfil, tus partidas y tu progreso. Esta acción no se puede deshacer. Si tienes Premium, cancela la suscripción desde Google Play o App Store: eliminar la cuenta no la cancela.'**
  String get profileDeleteBody;

  /// No description provided for @profileDeleteCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get profileDeleteCancel;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get profileDeleteConfirm;

  /// No description provided for @profileDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos eliminar tu cuenta. Inténtalo de nuevo o escríbenos a fejcavallo@gmail.com'**
  String get profileDeleteError;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
