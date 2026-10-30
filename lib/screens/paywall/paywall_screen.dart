import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../models/adventure.dart';
import '../../services/purchases.dart';
import '../../state/app_state.dart';

// Paywall, "Desbloquea todos los mitos": los beneficios que existen (las
// aventuras ya escritas que abre, sin anuncios, pago único), el precio de la
// tienda, "Comprar", "Restaurar compra" y "Ahora no". Se abre desde una
// aventura con candado (llega como argumento) o desde Ajustes (sin argumento).
// Cuando la compra queda hecha, se cierra y abre esa aventura en "Tu héroe"
// (o vuelve a Ajustes).
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late final AppState _appState;
  bool _closing = false; // ya se está cerrando por la compra
  bool _restoring = false; // consultando las compras pasadas

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppState>();
    _appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  // La compra quedó hecha (comprada o restaurada): avisa, se cierra y abre la
  // aventura que la trajo hasta acá.
  void _onAppStateChanged() {
    if (!_appState.purchased || _closing || !mounted) return;
    _closing = true;
    final l10n = AppLocalizations.of(context);
    final adventure = ModalRoute.of(context)!.settings.arguments as Adventure?;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.purchaseDone)));
    if (adventure == null) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.heroIntro, arguments: adventure);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _restoring = true);
    final result = await context.read<PurchasesService>().restore();
    if (!mounted) return;
    setState(() => _restoring = false);
    // Si la encontró, ya se está cerrando (ver _onAppStateChanged).
    final message = switch (result) {
      RestoreResult.found => null,
      RestoreResult.notFound => l10n.restoreNotFound,
      RestoreResult.failed => l10n.restoreFailed,
    };
    if (message != null) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final purchases = context.watch<PurchasesService>();
    final written = context.watch<AppState>().writtenPaidAdventures;
    final price = purchases.price;
    final canBuy = price != null && !purchases.pending && !_restoring && !_closing;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Empieza y termina en el fondo, así se une con la barra de arriba.
            colors: [
              context.palette.background,
              context.palette.softGold.withValues(alpha: 0.10),
              context.palette.background,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Icon(Icons.auto_stories_outlined, color: context.palette.gold, size: 56),
              const SizedBox(height: 16),
              Text(l10n.paywallTitle, style: context.appText.title, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              if (written > 0) _Benefit(text: l10n.paywallAdventures(written)),
              _Benefit(text: l10n.paywallNoAds),
              _Benefit(text: l10n.paywallOneTime),
              const SizedBox(height: 28),
              if (price != null)
                Text(
                  price,
                  style: context.appText.title.copyWith(
                    color: context.palette.softGold,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  l10n.paywallUnavailable,
                  style: context.appText.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              if (purchases.pending) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.purchasePending,
                  style: context.appText.bodySecondary.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: canBuy ? purchases.buy : null,
                child: Text(l10n.paywallBuy),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _restoring || _closing ? null : _restore,
                child: Text(l10n.restorePurchase),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.paywallNotNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Un beneficio de la compra, con una tilde dorada.
class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: context.palette.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: context.appText.body)),
        ],
      ),
    );
  }
}
