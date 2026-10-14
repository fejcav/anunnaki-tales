// Reglas de los anuncios, como funciones puras: qué unidad se usa, cuándo se
// pide el consentimiento y cuándo hay banner o intersticial. No tocan
// pantallas ni el SDK: `services/ads.dart` les pasa los datos y aplica lo que
// se decide acá.

import '../config.dart';

// Los dos formatos que usa la app.
enum AdFormat { banner, interstitial }

// Un intersticial cargado caduca a la hora; se descarta un poco antes.
const interstitialMaxAge = Duration(minutes: 55);

// La unidad de anuncio según el formato, la plataforma y si es debug. En
// debug, siempre las de prueba de Google; las reales, solo en release.
String adUnitId(AdFormat format, {required bool ios, required bool debug}) {
  return switch ((format, ios, debug)) {
    (AdFormat.banner, false, true) => AppConfig.testAndroidBannerUnit,
    (AdFormat.banner, true, true) => AppConfig.testIosBannerUnit,
    (AdFormat.interstitial, false, true) => AppConfig.testAndroidInterstitialUnit,
    (AdFormat.interstitial, true, true) => AppConfig.testIosInterstitialUnit,
    (AdFormat.banner, false, false) => AppConfig.androidBannerUnit,
    (AdFormat.banner, true, false) => AppConfig.iosBannerUnit,
    (AdFormat.interstitial, false, false) => AppConfig.androidInterstitialUnit,
    (AdFormat.interstitial, true, false) => AppConfig.iosInterstitialUnit,
  };
}

// El consentimiento se pide (con el formulario si hace falta) solo si va a
// haber anuncios: con la compra hecha no se muestra nada.
bool shouldRequestConsent({required bool purchased}) => !purchased;

// Se puede pedir un anuncio (banner o precargar el intersticial): sin la
// compra y con el consentimiento resuelto.
bool canLoadAds({required bool purchased, required bool canRequestAds}) =>
    !purchased && canRequestAds;

// El intersticial sale una vez cada tantos "Empezar": el 1.º, el 4.º, el
// 7.º… Si en esa vuelta no estaba cargado, se pierde (no se acumula para el
// siguiente), así nunca salen dos seguidos.
const startsPerInterstitial = 3;

// Al tocar "Empezar": se muestra el intersticial solo sin la compra, si ya
// está cargado y no caducó, y si le toca a este "Empezar" (`adventureStarts`
// es cuántos van contados, incluido el actual). Si no, se sigue sin anuncio
// (nunca se espera).
bool shouldShowInterstitial({
  required bool purchased,
  required DateTime? loadedAt,
  required DateTime now,
  required int adventureStarts,
}) {
  if (purchased || loadedAt == null) return false;
  if (now.difference(loadedAt) >= interstitialMaxAge) return false;
  return (adventureStarts - 1) % startsPerInterstitial == 0;
}
