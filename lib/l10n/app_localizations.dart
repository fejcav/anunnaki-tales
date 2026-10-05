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

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAdPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad de anuncios'**
  String get settingsAdPrivacy;

  /// No description provided for @settingsLinkError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el enlace.'**
  String get settingsLinkError;

  /// No description provided for @settingsResetProgress.
  ///
  /// In es, this message translates to:
  /// **'Borrar progreso'**
  String get settingsResetProgress;

  /// No description provided for @settingsResetQuestion.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán la partida guardada y los finales descubiertos. Esto no se puede deshacer.'**
  String get settingsResetQuestion;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get settingsResetCancel;

  /// No description provided for @settingsResetDone.
  ///
  /// In es, this message translates to:
  /// **'Progreso borrado'**
  String get settingsResetDone;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} ({build})'**
  String settingsVersion(String version, String build);

  /// No description provided for @catalogLocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueada'**
  String get catalogLocked;

  /// No description provided for @paywallTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea todos los mitos'**
  String get paywallTitle;

  /// No description provided for @paywallAdventures.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 aventura más, ya escrita y lista para jugar} other{{count} aventuras más, ya escritas y listas para jugar}}'**
  String paywallAdventures(int count);

  /// No description provided for @paywallNoAds.
  ///
  /// In es, this message translates to:
  /// **'Sin anuncios'**
  String get paywallNoAds;

  /// No description provided for @paywallOneTime.
  ///
  /// In es, this message translates to:
  /// **'Pago único, sin suscripción'**
  String get paywallOneTime;

  /// No description provided for @paywallBuy.
  ///
  /// In es, this message translates to:
  /// **'Comprar'**
  String get paywallBuy;

  /// No description provided for @paywallNotNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get paywallNotNow;

  /// No description provided for @paywallUnavailable.
  ///
  /// In es, this message translates to:
  /// **'La tienda no está disponible ahora. Prueba más tarde.'**
  String get paywallUnavailable;

  /// No description provided for @restorePurchase.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compra'**
  String get restorePurchase;

  /// No description provided for @purchaseDone.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Todos los mitos están desbloqueados.'**
  String get purchaseDone;

  /// No description provided for @purchasePending.
  ///
  /// In es, this message translates to:
  /// **'Compra pendiente: se activará cuando la tienda confirme el pago.'**
  String get purchasePending;

  /// No description provided for @restoreNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos una compra para restaurar.'**
  String get restoreNotFound;

  /// No description provided for @restoreFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar con la tienda. Prueba más tarde.'**
  String get restoreFailed;

  /// No description provided for @settingsUnlockAll.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear todo'**
  String get settingsUnlockAll;

  /// No description provided for @settingsAllUnlocked.
  ///
  /// In es, this message translates to:
  /// **'Todo desbloqueado'**
  String get settingsAllUnlocked;

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
