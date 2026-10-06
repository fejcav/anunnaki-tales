# Anunnaki Tales — guía para Claude Code

Versión 0.4 · 6 de octubre de 2026 · Iteración 14 (iOS base con Codemagic). Desde la iteración 10 la app no tiene cuenta ni servidor en el código; historias escritas de antemano (decisión del 02/10/2026, en `docs/cambio-de-rumbo.md`). Esta copia (repo) es la oficial; la del Proyecto "Anunnaki Tales" de claude.ai es un espejo. El plan de iteraciones con los pedidos listos para pegar está en `docs/plan-migracion.md` (versión 2).

Anunnaki Tales es un juego narrativo para Android e iOS ambientado en la mitología mesopotámica: el jugador elige un mito y vive la historia de su protagonista escena por escena; en cada escena hay hasta tres opciones con distinto riesgo y, muchas veces, un dato histórico real. Las historias están escritas de antemano (en `assets/data/stories/`, una por aventura) y cada una tiene varios finales. No hay servidor ni cuenta: todo se guarda en el teléfono. Tres aventuras son gratis con anuncios; una compra única desbloquea todas y quita los anuncios. (Hasta el 02/10/2026 la app dependía de Supabase, de una IA en vivo y de RevenueCat; ver `docs/cambio-de-rumbo.md`.)

**Por qué este proyecto existe.** La app se hizo en FlutterFlow hasta el Build 11 (versión 1.0.0, versionCode 11, en prueba cerrada de Google Play). La cuenta de FlutterFlow pasó al plan Free, que no deja exportar código ni compilar, y Federico decidió no pagar suscripciones. Se reescribe como proyecto Flutter normal, igual que Ovun (su otra app), con los mismos IDs de AdMob, la misma ficha de Play Console, el mismo package y la misma clave de subida. El código viejo exportado de FlutterFlow (rama `flutterflow` del repo, congelada el 16/03/2026) sirve solo de referencia; no se copia.

El dueño del proyecto (Federico) tiene nivel básico de Dart/Flutter: puede correr la app y cambiar textos o valores, pero no quiere meterse en la lógica. Por eso: **la opción más simple que funcione, siempre**, y una explicación de una o dos líneas de cada pieza nueva cuando se la presentás.

## Identidad

- Application ID (Android) y bundle ID (iOS): **`com.mycompany.anunnakitales`**. Es el de la app ya publicada en Play Console: **no se cambia nunca** (cambiarlo crea otra app). Se genera con `flutter create --org com.mycompany --project-name anunnakitales`.
- Nombre visible: Anunnaki Tales. Subtítulo de pantalla de inicio: "Mitos Interactivos".
- Política de privacidad: `https://fejcav.github.io/anunnaki-tales-legal/privacy_policy.html`. Fuente en el repo `fejcav/anunnaki-tales-legal` (GitHub Pages).
- Repo: `fejcav/anunnaki-tales`, rama `main` (proyecto nuevo). La rama `flutterflow` queda como archivo histórico.
- Versión inicial del proyecto nuevo: **`1.1.0+12`**. Play ya recibió el versionCode 11: el número después del `+` tiene que ser siempre mayor que el último subido.

## Entorno

- Windows 11, Flutter estable en `C:\dev\flutter` (el mismo de Ovun), Android SDK en `C:\Users\fedec\AppData\Local\Android\Sdk`, Git.
- Proyecto en `C:\dev\anunnaki-tales`.
- **Dispositivo de prueba: emulador `Anunnaki_Pixel_8`**, propio de este proyecto (creado el 01/10/2026 como copia del `Pixel_8` de Ovun: mismo dispositivo, misma imagen Android 37.2 con Play Store), para no compartir datos ni emulador con otros proyectos. Se arranca siempre en el puerto 5560, así su nombre es fijo aunque el de Ovun esté abierto:
  `C:\Users\fedec\AppData\Local\Android\Sdk\emulator\emulator.exe -avd Anunnaki_Pixel_8 -port 5560 -no-snapshot`
  En `flutter devices` y `adb devices` aparece como `emulator-5560`. Cuando pidas `flutter run`, usá `-d emulator-5560`; con `adb`, `-s emulator-5560`. (También arranca con `flutter emulators --launch Anunnaki_Pixel_8`, pero entonces el número cambia según qué otros emuladores estén abiertos.)
- Sin Mac: iOS se compila en Codemagic (misma cuenta que Ovun; los 500 minutos gratis de macOS por mes se comparten entre las dos apps).

## Emuladores y disco compartidos con Ovun
- En esta PC también está el proyecto Ovun (C:\dev\ovun). Los dos comparten el disco C: y la system image de Android.
- Usá solo el emulador Anunnaki_Pixel_8. Nunca uses ni instales nada en el Pixel_8: es de Ovun.
- Con dos emuladores abiertos, los ids (emulator-5554, emulator-5556, emulator-5560…) dependen del orden de arranque: antes de cualquier comando de adb o de flutter run, confirmá el nombre con `adb -s <id> emu avd name` y usá siempre ese id con -s o -d.
- Antes de compilar o abrir el emulador, fijate que no haya un build de Gradle, un flutter run ni un emulador de Ovun corriendo; si lo hay, pará y avisá.
- Antes de compilar, mirá el espacio libre en C:. Si hay menos de 15 GB, pará y avisá.
- El emulador arranca en frío, sin snapshot, para ahorrar ~4 GB de disco: tarda un par de minutos en arrancar. No vuelvas a activar el arranque rápido.
- Al terminar, cerrá tu emulador, Gradle (gradlew --stop desde android/) y cualquier flutter run o adb logcat que hayas abierto.

## Stack (cerrado, no cambiar sin preguntar)

- Flutter estable, Dart. `provider` + `ChangeNotifier`. Sin Riverpod, Bloc ni generación de código (`build_runner` prohibido).
- Contenido: archivos JSON en `assets/data/` (catálogo e historias), leídos con `rootBundle`.
- Persistencia: `shared_preferences` con un único JSON serializado a mano (`toJson`/`fromJson`).
- Compra: `in_app_purchase` + `in_app_purchase_android` (desde la iteración 11), igual que Ovun.
- Anuncios: `google_mobile_ads` (AdMob + UMP), desde la iteración 12.
- `url_launcher` (política de privacidad), `package_info_plus` (versión real), `flutter_localizations` + `intl` con ARB (`flutter gen-l10n`, español e inglés; ningún texto de interfaz hardcodeado en los widgets), `flutter_animate` (sin Rive ni Lottie).
- Fuentes: archivos TTF **estáticos** en `assets/fonts/` (Cinzel para títulos, Lora para la narrativa, Inter para la interfaz; las tres con licencia OFL). **Sin el paquete `google_fonts`**. Imágenes: PNG en `assets/` con `Image.asset`, sin `flutter_svg`.
- Tests: `flutter_test` para la lógica en `lib/logic/`, para `LocalStore` (con `SharedPreferences.setMockInitialValues`) y para validar las historias.
- **Fuera del proyecto:** `supabase_flutter`, `purchases_flutter`, `google_sign_in`, `sign_in_with_apple`, `crypto`.
- Herramientas de desarrollo (no van en la app): `flutter_launcher_icons`, `flutter_native_splash`.

No agregues paquetes que no estén en esta lista sin proponerlo primero y explicar para qué.

## Estructura

```
lib/
  main.dart, app_theme.dart, config.dart (IDs de AdMob y del producto de compra)
  models/        Adventure, Story, StoryScene, StoryChoice, StoryEnding, LocalizedText, LocalData
  logic/
    story_rules.dart     funciones puras: validar una historia, escena siguiente, finales, camino más corto al final del mito
    risk_rules.dart      color y etiqueta de riesgo y de dificultad
    purchase_rules.dart  (iteración 11) qué hacer con cada evento de compra; qué aventuras están abiertas
    ads_rules.dart       (iteración 12) cuándo se muestra cada anuncio
  data/local_store.dart  ÚNICA clase que toca shared_preferences
  services/
    story_repository.dart  ÚNICA clase que lee assets/data (catálogo e historias)
    purchases.dart         (iteración 11) ÚNICA clase que toca in_app_purchase
    ads.dart               (iteración 12) ÚNICA clase que toca google_mobile_ads
  state/app_state.dart   (iteración 11) ChangeNotifier con el estado de la compra
  screens/       home/ catalog/ hero_intro/ gameplay/ ending/ paywall/ settings/
  widgets/       AdventureCard, ChoiceButton, HistoricalFactCard, StarsBackground, AdBanner
  l10n/          app_es.arb, app_en.arb
assets/
  data/catalog.json            las 10 aventuras (textos de tarjeta, dificultad, gratis o no, orden)
  data/stories/<id>.json       una historia por aventura (formato en docs/formato-historias.md)
  fonts/, icon/
test/
  story_validation_test.dart   valida todas las historias de assets/data/stories/
  story_rules_test.dart, risk_rules_test.dart, local_store_test.dart, (luego) purchase_rules_test.dart, ads_rules_test.dart
docs/
  cambio-de-rumbo.md, formato-historias.md, plan-migracion.md (v2), release.md
```

Principio: la lógica vive en funciones puras (`lib/logic/`) que reciben datos y devuelven datos. Las pantallas no calculan nada; los servicios no deciden nada.

## Contenido

- `assets/data/catalog.json`: lista de aventuras con `id`, `sortOrder`, `difficulty` (`easy|medium|hard`), `isFree`, `title`, `subtitle`, `description` (cada texto `{es, en}`). Se generó una sola vez desde la tabla `adventures` de Supabase (iteración 9, 04/10/2026) y desde ahí se edita a mano.
- `assets/data/stories/<id>.json`: formato y reglas en `docs/formato-historias.md`. El test `story_validation_test.dart` aplica esas reglas a todos los archivos; en modo estricto (para el release) exige el inglés completo.
- Las historias las escribe Cowork en el proyecto de claude.ai y Federico las aprueba. Claude Code no inventa ni reescribe texto narrativo: si encuentra un error, lo señala.
- Una aventura sin archivo de historia se muestra como "Próximamente".
- Si a un texto le falta el inglés, se muestra el español.

## Aspecto

La app publicada es oscura con dorado; se mantiene para que coincida con las capturas de la tienda. Decisión de diseño: títulos con serif (Cinzel) y narrativa en Lora, como las capturas y el kit de marca (la app de FlutterFlow usaba Inter en todo).

- Fondo `#0A0E1A`, superficie de tarjetas `#141927`, dorado `#D4A843` (títulos, bordes, botón principal), lapislázuli `#1A237E` (avatar de héroe, fondo de la barra de carga), texto `#FFFFFF`, texto secundario blanco al 70 %, dorado suave `#F0D68A` (degradado del Paywall).
- Riesgo de las opciones: bajo `#4CAF50`, medio `#FF9800`, alto `#E53935`. Dificultad del catálogo: fácil verde, media naranja, difícil rojo (mismos colores).
- Títulos en Cinzel, narrativa en Lora (16 px, interlineado 1,6), botones y etiquetas en Inter.
- Fondo con estrellas sutiles en Inicio, Catálogo, Héroe y Gameplay (widget `StarsBackground`, puntos fijos, sin animación costosa).
- Botón principal: dorado relleno con texto oscuro. Secundario: superficie oscura con texto dorado.
- Solo vertical.

## Reglas de juego

- **Inicio**: "ANUNNAKI TALES", "Mitos Interactivos", "Comenzar aventura" (va al Catálogo) y "Continuar partida" (solo si hay una partida guardada cuya historia y escena existen; muestra el título de la aventura). Arriba a la derecha, el ícono de Ajustes.
- **Catálogo** ("Elige tu aventura"): una tarjeta por aventura en `sortOrder`, con título, subtítulo, dificultad con color y "~N escenas" (camino más corto hasta el final del mito, calculado de la historia). Si ya descubrió finales: "Finales: N de M". Estados: abierta, **con candado** (no gratis, con historia y sin compra: tocarla abre el Paywall; al comprar o restaurar se cierra y se abre esa aventura) o **"Próximamente"** (sin historia; no se abre).
- **Tu héroe**: nombre y descripción del protagonista (`hero` de la historia), descripción de la aventura y "Empezar". Empezar una aventura reemplaza la partida guardada.
- **Gameplay**: arriba "Capítulo N · Título" y "Turno N" (cantidad de escenas vistas en esta partida); el texto en Lora, separado en párrafos por las líneas en blanco; la tarjeta "Dato histórico" si la escena tiene `fact`; las opciones con `ChoiceButton` (punto de color, texto, descripción y "Riesgo bajo / medio / alto"; una opción sin `risk` va sin punto ni etiqueta). Elegir es instantáneo. La partida se guarda en cada escena. La flecha atrás vuelve a Inicio.
- **Final**: tipo ("Final del mito", "Final alternativo", "Final trágico"), título en Cinzel, texto, dato histórico, "Finales descubiertos: N de M" y los botones "Volver a jugar", "Otra aventura" y, solo en finales trágicos, "Volver a la última decisión" (vuelve a la última escena del camino con más de una opción). Al llegar a un final se guarda como descubierto y se borra la partida guardada.
- **Ajustes**: "Desbloquear todo" o "Todo desbloqueado" (iteración 11), "Restaurar compra" (iteración 11), "Privacidad de anuncios" (solo si UMP lo exige, iteración 12), "Política de privacidad", "Borrar progreso" (con confirmación dentro de la pantalla: borra la partida guardada y los finales descubiertos, no la compra ni el idioma) y la versión.
- No hay límite diario ni cuenta.

## Compra única

- Producto no consumible **`anunnaki_completo`** en Google Play (y en App Store desde la iteración 15). Precio: el que devuelve la tienda, nunca escrito a mano.
- Desbloquea todas las aventuras y quita los anuncios. Paywall ("Desbloquea todos los mitos"): beneficios **solo los que existen** (las aventuras ya escritas, sin anuncios, pago único sin suscripción), precio de la tienda, "Comprar", "Restaurar compra" y "Ahora no".
- Se implementa como la compra "Sin anuncios" de Ovun (`C:\dev\ovun\lib\services\purchases.dart` y `lib\logic\purchase_rules.dart`, **solo como referencia de lectura; no se toca nada de Ovun**): escuchar `purchaseStream`, completar las compras pendientes, reconocerlas, restaurar al pedirlo ("Restaurar compra") y también al abrir la app si la compra no está guardada (en silencio: sin diálogo ni mensaje; si la tienda no contesta, se arranca con lo guardado), y guardar el estado en `localData` para arrancar sin esperar a la tienda.
- **En iOS no se consulta la tienda al arrancar** (restaurar puede pedir la contraseña de Apple sin que el usuario haya tocado nada): ahí la compra se recupera solo con el botón "Restaurar compra". La consulta silenciosa al abrir es solo de Android.

## Anuncios (AdMob)

- Editor `pub-8769741188201469` (compartido con Ovun).
- Android: app `ca-app-pub-8769741188201469~9074937716`, banner `ca-app-pub-8769741188201469/8471468333`, intersticial `ca-app-pub-8769741188201469/2511863946`.
- iOS: app `ca-app-pub-8769741188201469~2296085996`, banner `ca-app-pub-8769741188201469/5604775611`, intersticial `ca-app-pub-8769741188201469/1635275865`.
- En debug (`kDebugMode`) las unidades pasan a las de prueba de Google: Android banner `ca-app-pub-3940256099942544/6300978111`, intersticial `ca-app-pub-3940256099942544/1033173712`; iOS banner `ca-app-pub-3940256099942544/2934735716`, intersticial `ca-app-pub-3940256099942544/4411468910`. El ID de app es siempre el real.
- **Consentimiento**: mensaje UMP "Anunnaki Tales consentimiento UE" (ya publicado en AdMob → Privacidad y mensajería). Se pide con `requestConsentInfoUpdate` + `loadAndShowConsentFormIfRequired` al abrir el Catálogo por primera vez, antes del primer anuncio; nunca durante la lectura. `MobileAds.instance.initialize()` una sola vez, cuando `canRequestAds` es verdadero. En debug, `ConsentDebugSettings` con geografía EEE para probar el formulario.
- **Banner** (320×50) solo sin la compra hecha, al pie de Catálogo y de Tu héroe. Si no carga, el espacio queda vacío.
- **Intersticial** solo sin la compra hecha: al tocar "Empezar" (precargado al entrar a Tu héroe; si no está listo, se sigue sin anuncio).
- Nunca anuncios en Gameplay, Final, Paywall ni Ajustes.
- Reglas en `ads_rules.dart` (funciones puras con tests). Sin conexión no hay anuncios y nada se rompe.

## Datos en shared_preferences

Una sola clave, `localData`: JSON con `schemaVersion` 2, `language` (`null` = el del teléfono), `savedGame` (o `null`: `adventureId`, `sceneId`, `path` = lista de ids de las escenas vistas), `endingsFound` (`{ adventureId: [ids de finales] }`) y `purchased` (booleano, desde la iteración 11). Se guarda entero cada vez que cambia algo. Al leer un `schemaVersion` 1 se descarta la partida guardada vieja y el contador de elecciones. Si no se puede leer, se empieza de cero.

## Release

- **Firma.** Clave de subida registrada en Play Console: `upload-keystore-new.jks`, alias `upload` (RSA 2048). Se guarda en `C:\dev\keys\anunnaki-upload.jks`, fuera del repo, con respaldo fuera de la PC. `android/key.properties` (ignorado por git) tiene `storeFile`, `storePassword`, `keyAlias`, `keyPassword`; `android/key.properties.example` es la plantilla commiteada. Si falta `key.properties`, el build de release falla con un mensaje claro en vez de firmar con debug. **Nunca escribir la contraseña en este archivo ni en el repo.**
- **Versión.** `version` en `pubspec.yaml`: la parte antes del `+` es la visible; la de después es el versionCode y se incrementa en cada subida (el primero de este proyecto es 12).
- **Build.** `flutter build appbundle --release` en la PC; el `.aab` se sube a mano a Play Console → Prueba cerrada (Alpha). R8 activado, con las reglas que pida AdMob.
- **Antes de cada release:** `flutter test` con la validación de historias en modo estricto para las aventuras publicadas.
- **Ícono y splash.** `flutter_launcher_icons` y `flutter_native_splash` desde `assets/icon/icon.png` (fondo `#0A0E1A`; el PNG tiene canal alfa, así que para iOS va `remove_alpha_ios: true`, porque la App Store rechaza íconos con transparencia). El splash usa `assets/icon/splash.png` (el mismo ícono achicado sobre un lienzo transparente de 1152 px, porque Android 12+ recorta el centro en círculo). Regenerar el splash reescribe `AndroidManifest.xml` (le quitó `portrait` el 05/10/2026) e `ios/Runner/Info.plist`: revisar después que siga `android:screenOrientation="portrait"` y `android:label="Anunnaki Tales"`, y si no, restaurarlos con `git checkout`.
- **Manifest de release.** `INTERNET` y `com.google.android.gms.permission.AD_ID` declarados explícitamente (el de facturación lo agrega la librería de compras); meta-data `com.google.android.gms.ads.APPLICATION_ID` con el ID real.
- **iOS.** `codemagic.yaml` en la raíz, con la estructura del de Ovun. Hoy tiene `ios-check` (iteración 14): Mac mini M2, Flutter estable, `pub get`, `analyze`, tests con `STRICT_STORIES=true`, `pod install` y `flutter build ios --release --no-codesign`, 30 minutos como máximo, aviso por mail; no corre solo con cada push, se lanza a mano desde Codemagic. El workflow que firma (integración de App Store Connect) y sube a TestFlight llega en la iteración 15. `Info.plist`: `GADApplicationIdentifier` (ID de app de iOS), `SKAdNetworkItems` de Google, `NSUserTrackingUsageDescription` (ATT; en inglés, con la traducción en `ios/Runner/es.lproj/InfoPlist.strings`, registrado en el proyecto de Xcode), `UIRequiresFullScreen`, solo vertical (iPhone y iPad), `CFBundleDisplayName` "Anunnaki Tales", `CFBundleLocalizations` en/es. `ios/Podfile` con `platform :ios, '15.0'` (igual que el proyecto de Xcode). Los anuncios funcionan igual que en Android (unidades de iOS en release, de prueba en debug). Sin Sign in with Apple ni `GIDClientID` (no hay ingreso). Cómo correr `ios-check`: `docs/release.md`, sección iOS.
- **Prueba de release en el emulador.** El emulador cuenta como dispositivo de prueba de AdMob. En un teléfono propio, registrarlo como dispositivo de prueba antes de abrir un build de release.
- Receta completa en `docs/release.md` (Android desde la iteración 13; iOS con Codemagic desde la 14).

## Cómo trabajar

- Una tarea por pedido. Antes de dar algo por terminado: `flutter analyze` sin warnings y `flutter test` en verde. Si tocaste una pantalla, probala vos en el emulador (ver abajo) y pasale a Federico un resumen de lo que viste.
- **Pruebas en el emulador: las hace Claude Code** con `adb` (toques, texto, capturas de pantalla). Federico interviene solo si hace falta algo que Claude Code no puede hacer (por ejemplo, una compra con su cuenta de Google).
- Commits chicos y descriptivos en español. Hacé el commit al cerrar cada tarea.
- Código en inglés (nombres de clases, variables, archivos). Comentarios y mensajes de commit en español. Textos de interfaz en los ARB.
- Los textos de interfaz en español van en **español neutro (tú)**, igual que la app publicada ("Elige tu aventura", "Hazte Premium"): nada de voseo. Los comentarios y commits siguen en el español de Federico.
- Al terminar una tarea, resumí en 3–5 líneas qué archivos creaste y qué hace cada uno, sin jerga.
- Si una regla de este archivo se contradice con lo que Federico pide, señalalo antes de implementar.
- No refactorices lo que no te pidieron. No agregues abstracciones "por si acaso".
- Toda pantalla tiene una forma clara de volver (flecha atrás), salvo la de fin de aventura.
- No se modifica nada del backend (tablas, funciones, reglas) desde este repo sin preguntar: la app publicada (Build 11) usa el mismo backend hasta que el Build 12 la reemplace.
- Cuando se cambie una regla de juego, se actualizan en el mismo pedido este archivo, los textos en los dos idiomas y los tests.

## Fases

0–8. Hechas con la arquitectura vieja (8, Premium con RevenueCat, queda reemplazada).
9. Historias locales (el juego completo sin servidor).
10. Sin cuenta ni servidor (se quitan Supabase y RevenueCat).
11. Compra única.
12. Anuncios con consentimiento.
13. Release de Android (Build 12).
14–15. iOS con Codemagic y TestFlight.
En paralelo: contenido (una historia por vez) y limpieza de servicios viejos.

## Abiertos (preguntar antes de asumir)

- Precio de la compra única y qué aventuras son gratis (por defecto, las 3 con `isFree`: `gilgamesh_enkidu`, `descent_inanna`, `lugalbanda_anzu`).
- Si más adelante conviene una copia opcional en la nube, como en Ovun.
