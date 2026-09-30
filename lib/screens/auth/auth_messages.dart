import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';

// Validaciones de los campos y mensajes de error, compartidos por la pantalla
// de ingreso y la de cambiar contraseña. Devuelven null si está todo bien.

const minPasswordLength = 6; // lo que exige Supabase

String? validateEmail(AppLocalizations l10n, String? value) {
  final email = (value ?? '').trim();
  final looksValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  return looksValid ? null : l10n.authEmailInvalid;
}

String? validatePassword(AppLocalizations l10n, String? value) {
  return (value ?? '').length >= minPasswordLength
      ? null
      : l10n.authPasswordTooShort(minPasswordLength);
}

String? validateRepeat(AppLocalizations l10n, String? value, String original) {
  return value == original ? null : l10n.authPasswordsDontMatch;
}

// El código del correo tiene 6 dígitos, pero el largo se configura en
// Supabase ("Email OTP length"): por margen se acepta de 6 a 10.
String? validateResetCode(AppLocalizations l10n, String? value) {
  return RegExp(r'^\d{6,10}$').hasMatch((value ?? '').trim())
      ? null
      : l10n.resetCodeInvalid;
}

String authErrorMessage(AppLocalizations l10n, AuthFailure failure) {
  return switch (failure) {
    AuthFailure.invalidCredentials => l10n.authErrorInvalidCredentials,
    AuthFailure.emailTaken => l10n.authErrorEmailTaken,
    AuthFailure.weakPassword => l10n.authErrorWeakPassword,
    AuthFailure.samePassword => l10n.authErrorSamePassword,
    AuthFailure.invalidCode => l10n.authErrorInvalidCode,
    AuthFailure.tooManyRequests => l10n.authErrorTooManyRequests,
    AuthFailure.noConnection => l10n.authErrorNoConnection,
    AuthFailure.unknown => l10n.authErrorUnknown,
  };
}
