import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ads.dart';
import '../state/app_state.dart';

// El banner (320×50) al pie de Catálogo y Tu héroe. Sin la compra ocupa
// siempre 50 de alto, haya anuncio o no, así nada se mueve; con la compra no
// ocupa nada. Al aparecer pide el banner (la primera vez, antes pasa por el
// formulario de consentimiento) y al irse lo descarta.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late final AdsService _ads = context.read<AdsService>();

  @override
  void initState() {
    super.initState();
    // Se pide después del primer cuadro: pedirlo avisa a los que escuchan y
    // eso no puede pasar mientras se dibuja.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || context.read<AppState>().purchased) return;
      _ads.loadBanner(this);
    });
  }

  @override
  void dispose() {
    _ads.disposeBanner(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchased = context.select<AppState, bool>((s) => s.purchased);
    context.watch<AdsService>();
    if (purchased) {
      // Si la compra llega con la pantalla abierta, el banner se saca del
      // árbol en este cuadro y se descarta recién después: descartarlo
      // mientras se sigue dibujando tira una excepción.
      WidgetsBinding.instance.addPostFrameCallback((_) => _ads.disposeBanner(this));
      return const SafeArea(top: false, child: SizedBox.shrink());
    }
    final banner = _ads.bannerFor(this);
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 50,
        child: banner == null
            ? null
            : Center(child: SizedBox(width: 320, height: 50, child: banner)),
      ),
    );
  }
}
