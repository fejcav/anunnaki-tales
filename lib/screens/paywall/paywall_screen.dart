import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/purchases.dart';
import '../../state/app_state.dart';
import '../../widgets/stars_background.dart';

// Paywall: beneficios que existen (elecciones ilimitadas y sin anuncios), el
// plan mensual y el anual con los precios de la tienda, "Restaurar compra",
// "Continuar gratis" y el texto legal. Se cierra devolviendo `true` si quedó
// Premium y `false` si no.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<PremiumPlan>? _plans; // null mientras se cargan
  bool _busy = false; // comprando o restaurando

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _plans = null);
    final plans = await context.read<PurchasesService>().loadPlans();
    if (mounted) setState(() => _plans = plans);
  }

  Future<void> _buy(PremiumPeriod period) async {
    final l10n = AppLocalizations.of(context);
    final purchases = context.read<PurchasesService>();
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final result = await purchases.buy(period);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case BuyResult.premium:
        appState.setPremium(true);
        Navigator.of(context).pop(true);
      case BuyResult.cancelled:
        break;
      case BuyResult.failed:
        messenger.showSnackBar(SnackBar(content: Text(l10n.paywallBuyError)));
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final purchases = context.read<PurchasesService>();
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final premium = await purchases.restore();
    if (!mounted) return;
    setState(() => _busy = false);
    if (premium == true) {
      appState.setPremium(true);
      messenger.showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
      Navigator.of(context).pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(premium == null ? l10n.restoreError : l10n.restoreNotFound)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plans = _plans;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywallTitle)),
      body: StarsBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 48),
              const SizedBox(height: 16),
              Text(l10n.paywallHeadline, style: AppText.title, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _Benefit(text: l10n.paywallBenefitUnlimited),
              _Benefit(text: l10n.paywallBenefitNoAds),
              const SizedBox(height: 24),
              if (plans == null)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (plans.isEmpty) ...[
                Text(l10n.paywallLoadError, style: AppText.body, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _loadPlans, child: Text(l10n.retry)),
              ] else
                // La anual llega primero y va destacada.
                for (final plan in plans) ...[
                  _PlanCard(
                    title: plan.period == PremiumPeriod.annual ? l10n.paywallAnnual : l10n.paywallMonthly,
                    price: plan.period == PremiumPeriod.annual
                        ? l10n.paywallPerYear(plan.price)
                        : l10n.paywallPerMonth(plan.price),
                    badge: plan.period == PremiumPeriod.annual ? l10n.paywallPopular : null,
                    onTap: _busy ? null : () => _buy(plan.period),
                  ),
                  const SizedBox(height: 12),
                ],
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : _restore,
                child: Text(l10n.paywallRestore),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                child: Text(l10n.paywallContinueFree),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.paywallLegal,
                style: AppText.bodySecondary.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.gold, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body.copyWith(fontSize: 16))),
        ],
      ),
    );
  }
}

// Tarjeta de un plan. La destacada (con [badge]) lleva el degradado dorado.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.price, required this.onTap, this.badge});

  final String title;
  final String price;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = badge != null;
    final textColor = highlighted ? AppColors.background : AppColors.text;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: highlighted ? null : AppColors.surface,
            gradient: highlighted
                ? const LinearGradient(colors: [AppColors.gold, AppColors.softGold])
                : null,
            border: Border.all(color: AppColors.gold),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (highlighted)
                      Text(
                        badge!.toUpperCase(),
                        style: AppText.body.copyWith(
                          color: AppColors.lapis,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    Text(title, style: AppText.button.copyWith(color: textColor, fontSize: 18)),
                  ],
                ),
              ),
              Text(price, style: AppText.button.copyWith(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
