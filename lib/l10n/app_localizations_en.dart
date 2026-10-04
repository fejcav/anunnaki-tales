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
  String get paywallTitle => 'Premium';

  @override
  String get profileTitle => 'Profile';

  @override
  String get authTabSignIn => 'Sign in';

  @override
  String get authTabSignUp => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authRepeatPassword => 'Repeat password';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String authPasswordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get authPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get authErrorInvalidCredentials => 'Wrong email or password';

  @override
  String get authErrorEmailTaken => 'That email already has an account';

  @override
  String get authErrorWeakPassword =>
      'That password is too weak. Try a longer one.';

  @override
  String get authErrorSamePassword =>
      'The new password must be different from the old one';

  @override
  String get authErrorInvalidCode => 'The code is wrong or has expired';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Wait a while and try again.';

  @override
  String get authErrorNoConnection => 'No connection';

  @override
  String get authErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get resetTitle => 'Change password';

  @override
  String get resetEmailIntro =>
      'Enter your email and we\'ll send you a code to change your password.';

  @override
  String get resetSendCode => 'Send code';

  @override
  String resetCodeIntro(String email) {
    return 'We sent a code to $email. It may take a few minutes; check your spam folder too.';
  }

  @override
  String get resetCode => 'Code';

  @override
  String get resetCodeInvalid => 'The code has 6 to 10 digits';

  @override
  String get resetNewPassword => 'New password';

  @override
  String get resetConfirm => 'Change password';

  @override
  String get resetDone => 'Password changed';

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
  String get paywallHeadline => 'Unlock the power of the gods';

  @override
  String get paywallBenefitUnlimited => 'Unlimited choices every day';

  @override
  String get paywallBenefitNoAds => 'No ads';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallAnnual => 'Yearly';

  @override
  String paywallPerMonth(String price) {
    return '$price / month';
  }

  @override
  String paywallPerYear(String price) {
    return '$price / year';
  }

  @override
  String get paywallPopular => 'Most popular';

  @override
  String get paywallRestore => 'Restore purchase';

  @override
  String get paywallContinueFree => 'Continue for free';

  @override
  String get paywallLegal =>
      'The subscription renews automatically at the end of each period, at the same price, unless you cancel it at least 24 hours before in Google Play or the App Store. Payment is charged to your store account when you confirm the purchase.';

  @override
  String get paywallLoadError =>
      'We couldn\'t load the plans. Check your connection.';

  @override
  String get paywallBuyError =>
      'We couldn\'t complete the purchase. Try again.';

  @override
  String get restoreDone => 'Done: Premium active';

  @override
  String get restoreNotFound => 'We didn\'t find any purchases to restore.';

  @override
  String get restoreError =>
      'We couldn\'t restore your purchases. Check your connection.';

  @override
  String get profilePremium => 'Subscription';

  @override
  String get profilePremiumActive => 'Premium active';

  @override
  String get profileGetPremium => 'Go Premium';

  @override
  String get profileRestore => 'Restore purchases';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePrivacyPolicy => 'Privacy policy';

  @override
  String get profileLinkError => 'We couldn\'t open the link.';

  @override
  String profileVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteTitle => 'Delete your account?';

  @override
  String get profileDeleteBody =>
      'Your profile, your games and your progress will be deleted forever. This can\'t be undone. If you have Premium, cancel the subscription in Google Play or the App Store: deleting your account doesn\'t cancel it.';

  @override
  String get profileDeleteCancel => 'Cancel';

  @override
  String get profileDeleteConfirm => 'Delete';

  @override
  String get profileDeleteError =>
      'We couldn\'t delete your account. Try again or write to us at fejcavallo@gmail.com';

  @override
  String get back => 'Back';
}
