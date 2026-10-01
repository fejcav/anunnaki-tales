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
  String get heroSelectTitle => 'Choose your hero';

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
  String homeContinueDetail(String adventure, String hero) {
    return '$adventure · $hero';
  }

  @override
  String get homeGameNotFound => 'This game is no longer available';

  @override
  String get homeContinueError =>
      'We couldn\'t load the game. Check your connection.';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String catalogTurns(int count) {
    return '~$count turns';
  }

  @override
  String get catalogError =>
      'We couldn\'t load the adventures. Check your connection.';

  @override
  String get catalogEmpty => 'No adventures available yet.';

  @override
  String get retry => 'Retry';

  @override
  String get heroStart => 'Start';

  @override
  String get heroTraveler => 'Traveler';

  @override
  String get heroTravelerDescription =>
      'A nameless traveler on a road of their own.';

  @override
  String get heroPreparing => 'The narrator is preparing your adventure…';

  @override
  String get heroError =>
      'We couldn\'t load the heroes. Check your connection.';

  @override
  String get heroStartError =>
      'We couldn\'t start the adventure. Please try again.';

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
  String get gameplayThinking => 'The narrator is thinking…';

  @override
  String gameplayFreeChoices(int left, int total) {
    return 'Free choices today: $left of $total';
  }

  @override
  String get gameplayChoiceError =>
      'The narrator couldn\'t answer. Check your connection and try again.';

  @override
  String get historicalFactTitle => 'Historical fact';

  @override
  String get paywallComingSoon => 'Premium is coming soon';

  @override
  String get back => 'Back';
}
