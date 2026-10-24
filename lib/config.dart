// Datos fijos de la app.
class AppConfig {
  AppConfig._();

  // Política de privacidad (GitHub Pages, repo fejcav/anunnaki-tales-legal).
  static const privacyPolicyUrl =
      'https://fejcav.github.io/anunnaki-tales-legal/privacy_policy.html';

  // Ficha de la app en Google Play ("Calificar la app"): primero la app de
  // Play Store; si no está, la página web.
  static const playStoreMarketUrl = 'market://details?id=com.mycompany.anunnakitales';
  static const playStoreWebUrl =
      'https://play.google.com/store/apps/details?id=com.mycompany.anunnakitales';

  // Compra única que desbloquea todas las aventuras y quita los anuncios.
  // Producto no consumible; mismo id en Google Play y (más adelante) App Store.
  static const fullUnlockProductId = 'anunnaki_completo';

  // Unidades de anuncio de AdMob (editor pub-8769741188201469, el mismo de
  // Ovun). El ID de la app va en AndroidManifest.xml (y en Info.plist en iOS).
  static const androidBannerUnit = 'ca-app-pub-8769741188201469/8471468333';
  static const androidInterstitialUnit = 'ca-app-pub-8769741188201469/2511863946';
  static const iosBannerUnit = 'ca-app-pub-8769741188201469/5604775611';
  static const iosInterstitialUnit = 'ca-app-pub-8769741188201469/1635275865';

  // Unidades de prueba de Google: se usan en debug, así nunca se cargan
  // anuncios reales mientras se prueba.
  static const testAndroidBannerUnit = 'ca-app-pub-3940256099942544/6300978111';
  static const testAndroidInterstitialUnit = 'ca-app-pub-3940256099942544/1033173712';
  static const testIosBannerUnit = 'ca-app-pub-3940256099942544/2934735716';
  static const testIosInterstitialUnit = 'ca-app-pub-3940256099942544/4411468910';
}
