import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import 'auth_messages.dart';

// "¿Olvidaste tu contraseña?" en dos pasos: primero el correo (Supabase manda
// un código numérico), después el código y la contraseña nueva. Al terminar
// la sesión queda abierta y se va a Inicio.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.initialEmail});

  final String initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _codeSent = false;
  // El código se puede usar una sola vez: si ya se validó y falla el cambio
  // de contraseña, el reintento solo repite el cambio.
  bool _codeVerified = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _email.text.trim();
      if (!_codeSent) {
        await auth.sendPasswordResetCode(email);
        if (!mounted) return;
        setState(() {
          _codeSent = true;
          _loading = false;
        });
        return;
      }
      if (!_codeVerified) {
        await auth.verifyResetCode(email, _code.text.trim());
        _codeVerified = true;
      }
      await auth.updatePassword(_password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resetDone)),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } on AuthError catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = authErrorMessage(l10n, e.failure);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_codeSent) ...[
                Text(l10n.resetEmailIntro, style: AppText.bodySecondary),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: l10n.authEmail),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => validateEmail(l10n, v),
                ),
              ] else ...[
                Text(
                  l10n.resetCodeIntro(_email.text.trim()),
                  style: AppText.bodySecondary,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _code,
                  enabled: !_codeVerified,
                  decoration: InputDecoration(labelText: l10n.resetCode),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateResetCode(l10n, v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _password,
                  decoration: InputDecoration(labelText: l10n.resetNewPassword),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) => validatePassword(l10n, v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _repeat,
                  decoration: InputDecoration(labelText: l10n.authRepeatPassword),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) => validateRepeat(l10n, v, _password.text),
                ),
              ],
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: AppText.body.copyWith(color: AppColors.riskHigh),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_codeSent ? l10n.resetConfirm : l10n.resetSendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
