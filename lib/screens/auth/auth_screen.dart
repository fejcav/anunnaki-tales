import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../widgets/stars_background.dart';
import 'auth_messages.dart';
import 'reset_password_screen.dart';

// Ingreso con dos pestañas: "Ingresar" y "Crear cuenta". Es la única pantalla
// sin flecha atrás. Al entrar bien, reemplaza todo por Inicio.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: StarsBackground(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(l10n.homeTitle, style: AppText.logo, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(l10n.homeSubtitle, style: AppText.subtitle),
                const SizedBox(height: 32),
                TabBar(
                  labelColor: AppColors.gold,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.gold,
                  labelStyle: AppText.button,
                  tabs: [
                    Tab(text: l10n.authTabSignIn),
                    Tab(text: l10n.authTabSignUp),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _AuthForm(isSignUp: false),
                      _AuthForm(isSignUp: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.isSignUp});

  final bool isSignUp;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
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
      if (widget.isSignUp) {
        await auth.signUp(email, _password.text);
      } else {
        await auth.signIn(email, _password.text);
      }
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } on AuthError catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = authErrorMessage(l10n, e.failure);
      });
    }
  }

  void _openReset() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(initialEmail: _email.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: l10n.authEmail),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              validator: (v) => validateEmail(l10n, v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              decoration: InputDecoration(labelText: l10n.authPassword),
              obscureText: true,
              textInputAction:
                  widget.isSignUp ? TextInputAction.next : TextInputAction.done,
              onFieldSubmitted: widget.isSignUp ? null : (_) => _submit(),
              validator: (v) => validatePassword(l10n, v),
            ),
            if (widget.isSignUp) ...[
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
                  : Text(widget.isSignUp ? l10n.authTabSignUp : l10n.authTabSignIn),
            ),
            if (!widget.isSignUp) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : _openReset,
                child: Text(l10n.authForgotPassword),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
