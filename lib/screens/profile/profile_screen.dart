import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_theme.dart';
import '../../config.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/purchases.dart';
import '../../state/app_state.dart';

// Perfil: correo, Premium ("Premium activo" o "Hazte Premium"), restaurar
// compras, política de privacidad, versión, cerrar sesión y eliminar cuenta.
// Al cerrar sesión o eliminar la cuenta, AppState hace el logOut de RevenueCat.
// "Privacidad de anuncios" llega en la iteración 9.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PackageInfo? _info; // versión de la app; null mientras se lee
  bool _busy = false; // cerrando sesión o eliminando la cuenta
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _readVersion();
  }

  Future<void> _readVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _info = info);
  }

  Future<void> _openPrivacyPolicy() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      Uri.parse(AppConfig.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileLinkError)));
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final purchases = context.read<PurchasesService>();
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _restoring = true);
    final premium = await purchases.restore();
    if (!mounted) return;
    setState(() => _restoring = false);
    if (premium == true) appState.setPremium(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          premium == null
              ? l10n.restoreError
              : premium
              ? l10n.restoreDone
              : l10n.restoreNotFound,
        ),
      ),
    );
  }

  // Cierra la sesión y borra la partida guardada (el contador de elecciones
  // del día se mantiene: es del teléfono, no de la cuenta).
  Future<void> _signOut() async {
    final auth = context.read<AuthService>();
    final store = context.read<LocalStore>();
    setState(() => _busy = true);
    await store.clearGame();
    await auth.signOut();
    _goToAuth();
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthService>();
    final store = context.read<LocalStore>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.profileDeleteTitle, style: AppText.title),
        content: Text(l10n.profileDeleteBody, style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.profileDeleteCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.riskHigh),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.profileDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final deleted = await auth.deleteAccount();
    if (!deleted) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profileDeleteError),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }
    await store.clearAll();
    _goToAuth();
  }

  // Vuelve al ingreso sin dejar ninguna pantalla debajo.
  void _goToAuth() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.auth, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = context.read<AuthService>().currentEmail ?? '';
    final info = _info;
    final isPremium = context.watch<AppState>().isPremium;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.profileEmail, style: AppText.bodySecondary),
            const SizedBox(height: 4),
            Text(email, style: AppText.body.copyWith(fontSize: 16)),
            const SizedBox(height: 24),
            Text(l10n.profilePremium, style: AppText.bodySecondary),
            const SizedBox(height: 8),
            if (isPremium)
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.profilePremiumActive,
                    style: AppText.button.copyWith(color: AppColors.gold),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.paywall),
                child: Text(l10n.profileGetPremium),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _restoring ? null : _restore,
              child: _restoring
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.profileRestore),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _openPrivacyPolicy,
              child: Text(l10n.profilePrivacyPolicy),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _busy ? null : _signOut,
              child: Text(l10n.profileSignOut),
            ),
            const SizedBox(height: 32),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.riskHigh),
              onPressed: _busy ? null : _deleteAccount,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.profileDeleteAccount),
            ),
            const SizedBox(height: 24),
            if (info != null)
              Text(
                l10n.profileVersion(info.version, info.buildNumber),
                style: AppText.bodySecondary.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
