import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_theme.dart';
import '../../config.dart';
import '../../data/local_store.dart';
import '../../l10n/app_localizations.dart';

// Ajustes: política de privacidad, "Borrar progreso" y la versión.
// "Borrar progreso" pide confirmación dentro de la misma pantalla (sin
// diálogos): el botón se cambia por la pregunta con "Cancelar" y "Borrar".
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _info; // versión de la app; null mientras se lee
  bool _confirmingReset = false; // mostrando la pregunta de "Borrar progreso"

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
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsLinkError)));
    }
  }

  // Borra la partida guardada y los finales descubiertos.
  Future<void> _resetProgress() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await context.read<LocalStore>().clearProgress();
    if (!mounted) return;
    setState(() => _confirmingReset = false);
    messenger.showSnackBar(SnackBar(content: Text(l10n.settingsResetDone)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = _info;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            OutlinedButton(
              onPressed: _openPrivacyPolicy,
              child: Text(l10n.settingsPrivacyPolicy),
            ),
            const SizedBox(height: 16),
            if (_confirmingReset)
              _ResetConfirmation(
                onCancel: () => setState(() => _confirmingReset = false),
                onConfirm: _resetProgress,
              )
            else
              OutlinedButton(
                onPressed: () => setState(() => _confirmingReset = true),
                child: Text(l10n.settingsResetProgress),
              ),
            const SizedBox(height: 32),
            if (info != null)
              Text(
                l10n.settingsVersion(info.version, info.buildNumber),
                style: AppText.bodySecondary.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

// La pregunta de "Borrar progreso", en una tarjeta en lugar del botón.
class _ResetConfirmation extends StatelessWidget {
  const _ResetConfirmation({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.riskHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.settingsResetQuestion, style: AppText.body),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: Text(l10n.settingsResetCancel)),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.riskHigh),
                onPressed: onConfirm,
                child: Text(l10n.settingsResetConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
