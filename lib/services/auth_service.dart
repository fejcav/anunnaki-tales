import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

// Motivos de error que la pantalla sabe traducir a un mensaje simple.
enum AuthFailure {
  invalidCredentials,
  emailTaken,
  weakPassword,
  samePassword,
  invalidCode,
  tooManyRequests,
  noConnection,
  unknown,
}

class AuthError implements Exception {
  const AuthError(this.failure);

  final AuthFailure failure;
}

// ÚNICA clase que toca Supabase Auth. Si algo falla, lanza [AuthError] con el
// motivo ya clasificado; nunca deja pasar el texto técnico de Supabase.
class AuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  // Hay sesión guardada en el teléfono (Supabase la recupera al arrancar).
  bool get isSignedIn => _auth.currentSession != null;

  // Id del usuario con sesión abierta (null si no hay sesión).
  String? get currentUserId => _auth.currentUser?.id;

  // Correo del usuario con sesión abierta (null si no hay sesión).
  String? get currentEmail => _auth.currentUser?.email;

  Future<void> signIn(String email, String password) =>
      _run(() => _auth.signInWithPassword(email: email, password: password));

  // Con "Confirm email" desactivado, crear la cuenta ya deja la sesión abierta.
  Future<void> signUp(String email, String password) =>
      _run(() => _auth.signUp(email: email, password: password));

  // Manda el correo con el código numérico para cambiar la contraseña.
  Future<void> sendPasswordResetCode(String email) =>
      _run(() => _auth.resetPasswordForEmail(email));

  // Valida el código del correo. Si es correcto, Supabase abre la sesión.
  Future<void> verifyResetCode(String email, String code) => _run(
    () => _auth.verifyOTP(email: email, token: code, type: OtpType.recovery),
  );

  // Cambia la contraseña del usuario con sesión abierta.
  Future<void> updatePassword(String newPassword) =>
      _run(() => _auth.updateUser(UserAttributes(password: newPassword)));

  // Cierra la sesión. Supabase la borra del teléfono antes de avisar al
  // servidor; si ese aviso falla (sin conexión), la sesión igual queda cerrada.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  // Elimina la cuenta con la Edge Function delete-account (todo lo del usuario
  // cae en cascada) y cierra la sesión. Devuelve false si no se pudo borrar.
  Future<bool> deleteAccount() async {
    try {
      final response = await Supabase.instance.client.functions
          .invoke('delete-account')
          .timeout(const Duration(seconds: 20));
      final data = response.data;
      if (data is! Map || data['deleted'] != true) return false;
    } catch (_) {
      return false;
    }
    await signOut();
    return true;
  }

  Future<void> _run(Future<Object?> Function() action) async {
    try {
      await action();
    } on AuthRetryableFetchException {
      throw const AuthError(AuthFailure.noConnection);
    } on AuthException catch (e) {
      throw AuthError(_classify(e));
    } on SocketException {
      throw const AuthError(AuthFailure.noConnection);
    } on TimeoutException {
      throw const AuthError(AuthFailure.noConnection);
    } catch (_) {
      throw const AuthError(AuthFailure.unknown);
    }
  }

  // Códigos de https://supabase.com/docs/guides/auth/debugging/error-codes
  AuthFailure _classify(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return AuthFailure.invalidCredentials;
      case 'user_already_exists':
      case 'email_exists':
        return AuthFailure.emailTaken;
      case 'weak_password':
        return AuthFailure.weakPassword;
      case 'same_password':
        return AuthFailure.samePassword;
      case 'otp_expired':
        return AuthFailure.invalidCode;
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return AuthFailure.tooManyRequests;
    }
    if (e.statusCode == '429') return AuthFailure.tooManyRequests;
    return AuthFailure.unknown;
  }
}
