// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Anunnaki Tales';

  @override
  String get homeTitle => 'ANUNNAKI TALES';

  @override
  String get homeSubtitle => 'Interactive Myths';

  @override
  String get catalogTitle => 'Choose your adventure';

  @override
  String get gameplayTitle => 'Adventure';

  @override
  String get homeStart => 'Start adventure';

  @override
  String get homeContinue => 'Continue game';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get catalogEmpty => 'No adventures available yet.';

  @override
  String get retry => 'Retry';

  @override
  String get heroStart => 'Start';

  @override
  String get riskLow => 'Low risk';

  @override
  String get riskMedium => 'Medium risk';

  @override
  String get riskHigh => 'High risk';

  @override
  String gameplayTurn(int turn) {
    return 'Turn $turn';
  }

  @override
  String get historicalFactTitle => 'Historical fact';

  @override
  String get heroIntroTitle => 'Your hero';

  @override
  String get heroIntroAdventure => 'The adventure';

  @override
  String get storyLoadError => 'We couldn\'t open this story.';

  @override
  String catalogScenes(int count) {
    return '~$count scenes';
  }

  @override
  String catalogEndings(int found, int total) {
    return 'Endings: $found of $total';
  }

  @override
  String get catalogComingSoon => 'Coming soon';

  @override
  String get catalogError => 'We couldn\'t load the adventures.';

  @override
  String gameplayChapter(int number, String title) {
    return 'Chapter $number · $title';
  }

  @override
  String gameplayChapterNumber(int number) {
    return 'Chapter $number';
  }

  @override
  String get endingTypeMyth => 'Ending of the myth';

  @override
  String get endingTypeAlternative => 'Alternative ending';

  @override
  String get endingTypeTragic => 'Tragic ending';

  @override
  String endingFound(int found, int total) {
    return 'Endings discovered: $found of $total';
  }

  @override
  String get endingPlayAgain => 'Play again';

  @override
  String get endingOtherAdventure => 'Another adventure';

  @override
  String get endingLastDecision => 'Back to the last decision';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsLinkError => 'We couldn\'t open the link.';

  @override
  String get settingsResetProgress => 'Delete progress';

  @override
  String get settingsResetQuestion =>
      'Your saved game and discovered endings will be deleted. This can\'t be undone.';

  @override
  String get settingsResetConfirm => 'Delete';

  @override
  String get settingsResetCancel => 'Cancel';

  @override
  String get settingsResetDone => 'Progress deleted';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get catalogLocked => 'Locked';

  @override
  String get paywallTitle => 'Unlock all myths';

  @override
  String paywallAdventures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more adventures, already written and ready to play',
      one: '1 more adventure, already written and ready to play',
    );
    return '$_temp0';
  }

  @override
  String get paywallNoAds => 'No ads';

  @override
  String get paywallOneTime => 'One-time payment, no subscription';

  @override
  String get paywallBuy => 'Buy';

  @override
  String get paywallNotNow => 'Not now';

  @override
  String get paywallUnavailable =>
      'The store isn\'t available right now. Try again later.';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get purchaseDone => 'Done! All myths are unlocked.';

  @override
  String get purchasePending =>
      'Purchase pending: it will be activated when the store confirms the payment.';

  @override
  String get restoreNotFound => 'We couldn\'t find a purchase to restore.';

  @override
  String get restoreFailed =>
      'We couldn\'t connect to the store. Try again later.';

  @override
  String get settingsUnlockAll => 'Unlock everything';

  @override
  String get settingsAllUnlocked => 'Everything unlocked';

  @override
  String get back => 'Back';
}
