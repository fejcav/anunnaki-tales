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
}
