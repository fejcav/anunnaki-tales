import 'package:anunnakitales/config.dart';
import 'package:anunnakitales/logic/ads_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('adUnitId', () {
    test('en debug, siempre las unidades de prueba de Google', () {
      for (final format in AdFormat.values) {
        for (final ios in [false, true]) {
          expect(
            adUnitId(format, ios: ios, debug: true),
            startsWith('ca-app-pub-3940256099942544/'),
          );
        }
      }
    });

    test('en release, las reales de cada plataforma', () {
      expect(adUnitId(AdFormat.banner, ios: false, debug: false), AppConfig.androidBannerUnit);
      expect(
        adUnitId(AdFormat.interstitial, ios: false, debug: false),
        AppConfig.androidInterstitialUnit,
      );
      expect(adUnitId(AdFormat.banner, ios: true, debug: false), AppConfig.iosBannerUnit);
      expect(
        adUnitId(AdFormat.interstitial, ios: true, debug: false),
        AppConfig.iosInterstitialUnit,
      );
    });

    test('las reales son del editor de Anunnaki Tales', () {
      for (final format in AdFormat.values) {
        for (final ios in [false, true]) {
          expect(
            adUnitId(format, ios: ios, debug: false),
            startsWith('ca-app-pub-8769741188201469/'),
          );
        }
      }
    });

    test('las de prueba son las de Google para cada formato', () {
      expect(
        adUnitId(AdFormat.banner, ios: false, debug: true),
        'ca-app-pub-3940256099942544/6300978111',
      );
      expect(
        adUnitId(AdFormat.interstitial, ios: false, debug: true),
        'ca-app-pub-3940256099942544/1033173712',
      );
      expect(
        adUnitId(AdFormat.banner, ios: true, debug: true),
        'ca-app-pub-3940256099942544/2934735716',
      );
      expect(
        adUnitId(AdFormat.interstitial, ios: true, debug: true),
        'ca-app-pub-3940256099942544/4411468910',
      );
    });
  });

  group('shouldRequestConsent', () {
    test('sin la compra se pide; con la compra, no', () {
      expect(shouldRequestConsent(purchased: false), isTrue);
      expect(shouldRequestConsent(purchased: true), isFalse);
    });
  });

  group('canLoadAds', () {
    test('solo sin la compra y con el consentimiento resuelto', () {
      expect(canLoadAds(purchased: false, canRequestAds: true), isTrue);
      expect(canLoadAds(purchased: false, canRequestAds: false), isFalse);
      expect(canLoadAds(purchased: true, canRequestAds: true), isFalse);
      expect(canLoadAds(purchased: true, canRequestAds: false), isFalse);
    });
  });

  group('shouldShowInterstitial', () {
    final now = DateTime(2026, 10, 5, 12);

    test('cargado hace poco y sin la compra: se muestra', () {
      expect(
        shouldShowInterstitial(
          purchased: false,
          loadedAt: now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        isTrue,
      );
    });

    test('con la compra hecha, nunca', () {
      expect(
        shouldShowInterstitial(
          purchased: true,
          loadedAt: now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        isFalse,
      );
    });

    test('si no está cargado, se sigue sin anuncio', () {
      expect(shouldShowInterstitial(purchased: false, loadedAt: null, now: now), isFalse);
    });

    test('cargado hace 55 minutos o más ya caducó', () {
      expect(
        shouldShowInterstitial(
          purchased: false,
          loadedAt: now.subtract(interstitialMaxAge),
          now: now,
        ),
        isFalse,
      );
      expect(
        shouldShowInterstitial(
          purchased: false,
          loadedAt: now.subtract(const Duration(minutes: 54, seconds: 59)),
          now: now,
        ),
        isTrue,
      );
    });
  });
}
