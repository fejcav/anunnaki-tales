import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

import '../logic/ads_rules.dart';
import '../state/app_state.dart';

// Hashes de teléfonos de prueba para el formulario de consentimiento. El
// emulador no lo necesita (UMP lo trata como de prueba solo). Para probar en
// un teléfono: con la lista vacía, UMP escribe en logcat
// 'addTestDeviceHashedId("...")' y ese valor va acá. Solo cuenta en debug.
const List<String> _umpTestDeviceIds = <String>[];

// En debug el formulario se prueba como si el teléfono estuviera en el EEE.
// Para ver cómo se comporta fuera, cambiar a `debugGeographyDisabled`.
const DebugGeography _debugGeography = DebugGeography.debugGeographyEea;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

// ÚNICA clase que toca `google_mobile_ads` (AdMob y el consentimiento UMP).
// Pide el consentimiento la primera vez que se abre el Catálogo, inicia el
// SDK una sola vez, carga el banner de Catálogo y Tu héroe y el intersticial
// de "Empezar". Qué unidad usar y cuándo hay anuncio lo decide
// `logic/ads_rules.dart`. Con la compra hecha no se pide nada. Un error del
// SDK (o no tener conexión) se anota con `debugPrint` y no rompe nada: sin
// anuncio, el lugar del banner queda vacío y "Empezar" sigue directo.
class AdsService extends ChangeNotifier {
  AdsService({required this.appState});

  final AppState appState;

  // `MobileAds.instance.initialize()` va una sola vez.
  Future<void>? _initializing;

  // El pedido de consentimiento de esta corrida (con formulario si hace
  // falta). Una vez resuelto no se vuelve a pedir hasta el próximo arranque.
  Future<bool>? _consent;

  bool _canRequestAds = false;

  // UMP dice que hay que ofrecer "Privacidad de anuncios" en Ajustes.
  bool _privacyOptionsRequired = false;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  BannerAd? _banner;
  bool _bannerLoaded = false;
  Object? _bannerOwner;

  InterstitialAd? _interstitial;
  DateTime? _interstitialLoadedAt;
  bool _interstitialLoading = false;

  // ------------------------------------------------------------ consentimiento

  // Al arrancar: lee lo que quedó del consentimiento en otra corrida (sin
  // formulario) y, si ya se pueden pedir anuncios, inicia el SDK.
  Future<void> start() async {
    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      _privacyOptionsRequired = await _readPrivacyOptionsRequired();
      if (canLoadAds(purchased: appState.purchased, canRequestAds: _canRequestAds)) {
        await _initialize();
      }
    } catch (error) {
      debugPrint('Anuncios: no se pudo leer el consentimiento: $error');
    }
    notifyListeners();
  }

  // Pide el consentimiento (con el formulario, si hace falta) e inicia el
  // SDK si se puede. Lo llama el banner del Catálogo al abrirse. Devuelve si
  // se pueden pedir anuncios.
  Future<bool> ensureConsent() async {
    if (!shouldRequestConsent(purchased: appState.purchased)) return false;
    return _consent ??= _requestConsent();
  }

  Future<bool> _requestConsent() async {
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(
          consentDebugSettings: kDebugMode
              ? ConsentDebugSettings(
                  debugGeography: _debugGeography,
                  testIdentifiers: _umpTestDeviceIds,
                )
              : null,
        ),
        updated.complete,
        (FormError error) => updated.completeError(error.message),
      );
      await updated.future;

      final shown = Completer<void>();
      await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) debugPrint('Anuncios: formulario de consentimiento: ${error.message}');
        shown.complete();
      });
      await shown.future;

      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      _privacyOptionsRequired = await _readPrivacyOptionsRequired();
      if (_canRequestAds) await _initialize();
    } catch (error) {
      debugPrint('Anuncios: no se pudo pedir el consentimiento: $error');
      // Sin conexión, por ejemplo: se vuelve a intentar la próxima vez.
      _consent = null;
    }
    notifyListeners();
    return _canRequestAds;
  }

  Future<bool> _readPrivacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  Future<void> _initialize() => _initializing ??= MobileAds.instance.initialize().then((_) {});

  // "Privacidad de anuncios" en Ajustes: vuelve a abrir el formulario.
  Future<void> showPrivacyOptions() async {
    try {
      final shown = Completer<void>();
      await ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (error != null) debugPrint('Anuncios: privacidad de anuncios: ${error.message}');
        shown.complete();
      });
      await shown.future;
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      _privacyOptionsRequired = await _readPrivacyOptionsRequired();
      if (_canRequestAds) await _initialize();
    } catch (error) {
      debugPrint('Anuncios: no se pudo abrir la privacidad: $error');
    }
    notifyListeners();
  }

  // ------------------------------------------------------------------ banner

  // El banner cargado de [owner] (el `AdBanner` que lo pidió), o null.
  Widget? bannerFor(Object owner) {
    final banner = _banner;
    if (banner == null || !_bannerLoaded || _bannerOwner != owner) return null;
    return AdWidget(ad: banner);
  }

  // Carga el banner para [owner]. Si había otro (de la pantalla anterior), lo
  // descarta: hay uno solo a la vez. La primera vez pasa por el
  // consentimiento.
  Future<void> loadBanner(Object owner) async {
    _disposeBannerAd();
    _bannerOwner = owner;
    notifyListeners();
    final allowed = await ensureConsent();
    if (_bannerOwner != owner) return;
    if (!canLoadAds(purchased: appState.purchased, canRequestAds: allowed)) return;
    final banner = BannerAd(
      adUnitId: adUnitId(AdFormat.banner, ios: _isIOS, debug: kDebugMode),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!identical(ad, _banner)) return;
          _bannerLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Anuncios: el banner no cargó: ${error.message}');
          ad.dispose();
          if (identical(ad, _banner)) {
            _banner = null;
            notifyListeners();
          }
        },
      ),
    );
    _banner = banner;
    try {
      await banner.load();
    } catch (error) {
      debugPrint('Anuncios: el banner no cargó: $error');
    }
  }

  // Descarta el banner de [owner] al salir de la pantalla. Si ya lo tomó otra,
  // no hace nada. No avisa a nadie: se llama mientras Flutter desarma el
  // widget, y ahí no se puede pedir que nada se redibuje.
  void disposeBanner(Object owner) {
    if (_bannerOwner != owner) return;
    _bannerOwner = null;
    _disposeBannerAd();
  }

  void _disposeBannerAd() {
    _banner?.dispose();
    _banner = null;
    _bannerLoaded = false;
  }

  // ------------------------------------------------------------- intersticial

  // Al entrar a Tu héroe: deja cargado el intersticial de "Empezar". No
  // muestra el formulario (eso pasa en el Catálogo).
  Future<void> preloadInterstitial() async {
    _dropStaleInterstitial();
    if (_interstitial != null || _interstitialLoading) return;
    final consent = _consent;
    if (consent != null) await consent;
    if (!canLoadAds(purchased: appState.purchased, canRequestAds: _canRequestAds)) return;
    _interstitialLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: adUnitId(AdFormat.interstitial, ios: _isIOS, debug: kDebugMode),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitial = ad;
            _interstitialLoadedAt = DateTime.now();
            _interstitialLoading = false;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Anuncios: el intersticial no cargó: ${error.message}');
            _interstitialLoading = false;
          },
        ),
      );
    } catch (error) {
      debugPrint('Anuncios: el intersticial no cargó: $error');
      _interstitialLoading = false;
    }
  }

  // Al tocar "Empezar": si el intersticial está listo, lo muestra y termina
  // cuando el usuario lo cierra. Si no está listo, termina enseguida (se
  // sigue sin anuncio).
  Future<void> showInterstitialIfReady() async {
    final ad = _interstitial;
    final show = shouldShowInterstitial(
      purchased: appState.purchased,
      loadedAt: _interstitialLoadedAt,
      now: DateTime.now(),
    );
    if (ad == null || !show) {
      _dropStaleInterstitial();
      return;
    }
    _interstitial = null;
    _interstitialLoadedAt = null;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('Anuncios: el intersticial no se mostró: ${error.message}');
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    try {
      await ad.show();
      await closed.future;
    } catch (error) {
      debugPrint('Anuncios: el intersticial falló: $error');
    }
  }

  void _dropStaleInterstitial() {
    final loadedAt = _interstitialLoadedAt;
    if (loadedAt == null) return;
    if (DateTime.now().difference(loadedAt) < interstitialMaxAge) return;
    _interstitial?.dispose();
    _interstitial = null;
    _interstitialLoadedAt = null;
  }

  @override
  void dispose() {
    _disposeBannerAd();
    _interstitial?.dispose();
    super.dispose();
  }
}
