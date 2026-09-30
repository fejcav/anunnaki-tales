# Anunnaki Tales — guía para Claude Code

Versión 0.1 · 30 de septiembre de 2026 · Migración desde FlutterFlow a Flutter puro, iteración 0 (preparación). Esta copia (repo) es la oficial; la del Proyecto "Anunnaki Tales" de claude.ai es un espejo. El plan de iteraciones con los pedidos listos para pegar está en `docs/plan-migracion.md`.

Anunnaki Tales es un juego narrativo para Android e iOS ambientado en la mitología mesopotámica: el jugador elige un mito, elige un héroe y la IA (Claude Haiku 4.5, detrás de una Edge Function de Supabase) narra la historia escena por escena; en cada escena hay tres opciones con distinto riesgo y un dato histórico real. Gratis con anuncios y 3 elecciones por día; Premium por suscripción (RevenueCat) quita los anuncios y el límite.

**Por qué este proyecto existe.** La app se hizo en FlutterFlow hasta el Build 11 (versión 1.0.0, versionCode 11, en prueba cerrada de Google Play). La cuenta de FlutterFlow pasó al plan Free, que no deja exportar código ni compilar, y Federico decidió no pagar suscripciones. Se reescribe como proyecto Flutter normal, igual que Ovun (su otra app), con **todo el backend intacto**: misma base de Supabase, mismas funciones, mismo RevenueCat, mismos IDs de AdMob, misma ficha de Play Console, mismo package y misma clave de subida. El código viejo exportado de FlutterFlow (rama `flutterflow` del repo, congelada el 16/03/2026) sirve solo de referencia; no se copia.

El dueño del proyecto (Federico) tiene nivel básico de Dart/Flutter: puede correr la app y cambiar textos o valores, pero no quiere meterse en la lógica. Por eso: **la opción más simple que funcione, siempre**, y una explicación de una o dos líneas de cada pieza nueva cuando se la presentás.

## Identidad

- Application ID (Android) y bundle ID (iOS): **`com.mycompany.anunnakitales`**. Es el de la app ya publicada en Play Console: **no se cambia nunca** (cambiarlo crea otra app). Se genera con `flutter create --org com.mycompany --project-name anunnakitales`.
- Nombre visible: Anunnaki Tales. Subtítulo de pantalla de inicio: "Mitos Interactivos".
- Política de privacidad: `https://fejcav.github.io/anunnaki-tales-legal/privacy_policy.html`. Eliminar cuenta (página pública): `https://fejcav.github.io/anunnaki-tales-legal/delete_account.html`. Fuente en el repo `fejcav/anunnaki-tales-legal` (GitHub Pages).
- Repo: `fejcav/anunnaki-tales`, rama `main` (proyecto nuevo). La rama `flutterflow` queda como archivo histórico.
- Versión inicial del proyecto nuevo: **`1.1.0+12`**. Play ya recibió el versionCode 11: el número después del `+` tiene que ser siempre mayor que el último subido.

## Entorno

- Windows 11, Flutter estable en `C:\dev\flutter` (el mismo de Ovun), Android SDK en `C:\Users\fedec\AppData\Local\Android\Sdk`, Git.
- Proyecto en `C:\dev\anunnaki-tales`.
- **Dispositivo de prueba: emulador Pixel 8** (el mismo de Ovun). Se arranca con `flutter emulators --launch Pixel_8`; en `flutter devices` aparece como `emulator-5554`. Cuando pidas `flutter run`, usá `-d emulator-5554`.
- Sin Mac: iOS se compila en Codemagic (misma cuenta que Ovun; los 500 minutos gratis de macOS por mes se comparten entre las dos apps).

## Stack (cerrado, no cambiar sin preguntar)

- Flutter estable, Dart. Se desarrolla y prueba en Android; iOS se compila después en Codemagic.
- Estado: `provider` + `ChangeNotifier`. Nada de Riverpod, Bloc ni generación de código (`build_runner` prohibido).
- Backend: `supabase_flutter` (Auth, lectura de tablas y llamadas a Edge Functions con `functions.invoke`, que manda solo el `apikey` y el JWT del usuario).
- Suscripción: `purchases_flutter` (RevenueCat). Entitlement `premium`.
- Anuncios: `google_mobile_ads` (AdMob + SDK de consentimiento UMP).
- Persistencia local: `shared_preferences` con un único JSON serializado a mano (`toJson`/`fromJson`).
- Enlaces externos: `url_launcher` (política de privacidad desde Perfil).
- Versión de la app: `package_info_plus` (Perfil muestra la versión real).
- Animaciones: Flutter nativo + `flutter_animate`. Sin Rive ni Lottie.
- Fuentes: archivos TTF **estáticos** en `assets/fonts/` (Cinzel para títulos, Lora para la narrativa, Inter para la interfaz; las tres con licencia OFL). Se bajan de fonts.google.com ("Download family", carpeta `static/` del ZIP); el repo google/fonts de GitHub hoy solo tiene las variables. **Sin el paquete `google_fonts`** (baja las fuentes de internet al arrancar).
- Imágenes: PNG en `assets/` con `Image.asset`. Sin `flutter_svg`.
- Idiomas: `flutter_localizations` + `intl` con ARB (`flutter gen-l10n`), español e inglés. Ningún texto de interfaz hardcodeado en los widgets. El idioma de la narrativa es el mismo que el de la interfaz.
- Tests: `flutter_test` solo para la lógica en `lib/logic/`.
- Login con Google (iteración 11) e iOS con Apple (iteración 13): `google_sign_in` y `sign_in_with_apple` + `crypto` (hash del nonce), siempre entregando el token a Supabase con `signInWithIdToken`. Hasta esas iteraciones, solo email y contraseña.
- Herramientas de desarrollo (no van en la app): `flutter_launcher_icons`, `flutter_native_splash`.

No agregues paquetes que no estén en esta lista sin proponerlo primero y explicar para qué.

## Estructura

```
lib/
  main.dart                 arranque, providers, tema, rutas, orientación vertical
  app_theme.dart            colores y estilos de texto (ver "Aspecto")
  config.dart               URL y anon key de Supabase, claves públicas de RevenueCat, IDs de AdMob por plataforma
  models/                   Adventure, Character, StoryScene (narrativa, tono, opciones, turno, sessionId; dato histórico opcional), Choice, LocalData
  logic/
    choice_limit_rules.dart funciones puras: cuántas elecciones gratis quedan hoy, si se puede elegir, reinicio a medianoche local
    ads_rules.dart          funciones puras: cuándo se muestra banner / intersticial
    risk_rules.dart         funciones puras: color y etiqueta de cada nivel de riesgo (opciones) y de dificultad (catálogo)
  data/
    local_store.dart        ÚNICA clase que toca shared_preferences
  services/
    auth_service.dart       ÚNICA clase que toca Supabase Auth: sesión, registro, ingreso, recuperar contraseña, cerrar sesión, eliminar cuenta (Edge Function delete-account)
    story_api.dart          ÚNICA clase que lee tablas de Supabase y llama a la Edge Function narrative
    purchases.dart          ÚNICA clase que toca purchases_flutter
    ads.dart                ÚNICA clase que toca google_mobile_ads (consentimiento UMP, banner, intersticial)
  state/app_state.dart      ChangeNotifier: usuario, premium, escena actual, elecciones de hoy
  screens/                  auth/ home/ catalog/ hero_select/ gameplay/ paywall/ profile/
  widgets/                  AdventureCard, HeroCard, StatBar, ChoiceButton, HistoricalFactCard, NarratorLoading, AdBanner, StarsBackground
  l10n/                     app_es.arb, app_en.arb
assets/
  fonts/                    Cinzel, Lora, Inter (TTF)
  icon/icon.png             1024×1024 (el ícono actual de la tienda)
supabase/
  functions/narrative/index.ts        copia de la función desplegada (referencia; se despliega desde el dashboard)
  functions/delete-account/index.ts   copia de la función desplegada
test/
  choice_limit_rules_test.dart, ads_rules_test.dart, risk_rules_test.dart
docs/
  plan-migracion.md         iteraciones con los pedidos para Claude Code
  release.md                receta del release de Android y de iOS (se escribe en la iteración 10)
```

Principio: la lógica vive en funciones puras (`lib/logic/`) que reciben datos y devuelven datos. Las pantallas no calculan nada; los servicios no deciden nada.

## Backend (Supabase, no se toca desde la app)

- Proyecto `wtkohxujhvaxoablfevz`, URL `https://wtkohxujhvaxoablfevz.supabase.co`. La anon key es pública por diseño (la seguridad la dan las reglas RLS); se copia del dashboard (Project Settings → API) a `config.dart`. El plan free pausa el proyecto tras 7 días sin uso: si la app no conecta, lo primero es mirar si está pausado.
- Tablas que lee la app (todas con RLS; el catálogo es de lectura pública):
  - `adventures`: `id`, `myth_id`, `title_es/en`, `subtitle_es/en`, `description_es/en`, `difficulty` (`easy|medium|hard`), `estimated_turns`, `is_free`, `is_featured`, `is_active`, `sort_order`. El catálogo muestra las `is_active` ordenadas por `sort_order`.
  - `characters`: `id`, `name`, `title`, `description_es/en`, `role`, `stats` (JSONB con `strength`, `wisdom`, `charisma`, `divine_power`), `is_playable`, `is_premium`.
  - `adventure_characters`: `adventure_id`, `character_id`, `role_in_adventure`. Los héroes de una aventura se leen con `select('*, characters(*)')` filtrando por `adventure_id`, y **se muestran solo los que tienen `characters.is_playable = true`** (la tabla también vincula antagonistas y aliados como Tiamat o Enki). `characters.title` está solo en inglés: no se muestra; en su lugar va `description_es/en`.
  - `profiles` lo crea un trigger al registrarse; `game_sessions` lo escribe la Edge Function (columnas verificadas el 30/09/2026: `user_id`, `myth_id`, `difficulty`, `language`, `current_narrative`, `current_choices`, `current_mood`, `history`, `turn_count`, `status`; `adventure_id` es opcional); `turns` no se usa. La app no escribe en ninguna tabla.
- Todo lo del usuario borra en cascada desde `auth.users` (`profiles → game_sessions → turns`, `purchases`, `user_achievements`).
- **Edge Function `narrative`** (Claude Haiku 4.5, `claude-haiku-4-5-20251001`; copia exacta de la desplegada en `supabase/functions/narrative/index.ts`). Se llama con `supabase.functions.invoke('narrative', body: {...})` (nunca con `http.post` a mano: sin el header `apikey` responde 401). La función guarda la partida en `game_sessions` (historial, escena actual, opciones actuales, `turn_count`, `status`) y le manda a la IA las últimas 6 escenas como contexto. Acciones (formato verificado leyendo el código desplegado el 30/09/2026):
  - `start`: `{ "action": "start", "user_id": <id del usuario de Supabase>, "myth_id": <adventures.myth_id>, "player_name": <nombre del héroe>, "difficulty": "normal", "language": "es"|"en" }`. **Sin `user_id` no guarda la partida** y devuelve `session_id: null` (así falló la app de FlutterFlow: nunca lo mandaba). Si el guardado falla, la función igual responde 200 con `session_id: null`: **la app trata un `start` sin `session_id` como error** (no guarda nada, muestra "Reintentar").
  - `continue`: `{ "action": "continue", "session_id": "...", "choice_id": 1|2|3 }`. La función busca el texto de la opción en la partida guardada; el idioma y la dificultad salen de la partida. Sin `session_id` → 400; partida inexistente → 404.
  - `load`: `{ "action": "load", "session_id": "..." }`. No llama a la IA: devuelve `session_id`, `narrative`, `scene_mood`, `choices`, `turn_count`, `myth_id`, `status` de la partida guardada. Partida inexistente → 404.
  - Respuesta de `start` y `continue`: `narrative` (150–250 palabras), `scene_mood` (`epic|mysterious|dangerous|peaceful|sacred|tragic|triumphant`), `choices` (3 objetos con `id` numérico, `text`, `description`, `risk_level` `low|medium|high`), `session_id` y `turn_count` (número de escena). Si la IA no devuelve JSON válido, la función arma una escena de respaldo con el texto crudo y tres opciones genéricas; la app la muestra igual.
  - **No devuelve** `historical_fact`, `character_state` ni ninguna señal de final (el prompt actual no los pide): hoy las aventuras no terminan. Ver "Abiertos".
  - Errores: 400 (falta `action` o `session_id`, acción desconocida) y 404 (partida inexistente) responden solo `{ "error": "..." }`; 502 (falló la IA) y 500 (error inesperado) agregan `narrative` con un mensaje en español. Con cualquier código que no sea 2xx, `functions.invoke` **lanza `FunctionException`**: el código se lee de `e.status` (así se distingue el 404 de `load`). La app muestra su propio aviso traducido con "Reintentar"; nunca se cuelga ni muestra el texto técnico.
- **Edge Function `delete-account`**: `supabase.functions.invoke('delete-account')` sin body. Borra al usuario de Auth usando su propio JWT (todo lo demás cae en cascada). Responde `{ "deleted": true }` (200), 401 sin sesión, 500 si falla. No cancela suscripciones de las tiendas.
- Auth: email + contraseña con "Confirm email" **desactivado** en Supabase (el correo integrado de Supabase manda 2 mails por hora; no sirve para confirmar cuentas). Recuperar contraseña usa ese mismo correo con un **código de 6 dígitos** (plantilla "Reset Password" de Supabase con `{{ .Token }}`, se cambia en la iteración 2), porque un enlace necesitaría deep links y una página web.

## Aspecto

La app publicada es oscura con dorado; se mantiene para que coincida con las capturas de la tienda. Decisión de diseño: títulos con serif (Cinzel) y narrativa en Lora, como las capturas y el kit de marca (la app de FlutterFlow usaba Inter en todo).

- Fondo `#0A0E1A`, superficie de tarjetas `#141927`, dorado `#D4A843` (títulos, bordes, botón principal), lapislázuli `#1A237E` (avatar de héroe, fondo de barras), texto `#FFFFFF`, texto secundario blanco al 70 %, dorado suave `#F0D68A` (degradado del Paywall).
- Riesgo de las opciones: bajo `#4CAF50`, medio `#FF9800`, alto `#E53935`. Dificultad del catálogo: fácil verde, media naranja, difícil rojo (mismos colores).
- Títulos en Cinzel, narrativa en Lora (16 px, interlineado 1,6), botones y etiquetas en Inter.
- Fondo con estrellas sutiles en Inicio, Catálogo, Héroe y Gameplay (widget `StarsBackground`, puntos fijos, sin animación costosa).
- Botón principal: dorado relleno con texto oscuro. Secundario: superficie oscura con texto dorado.
- Solo vertical.

## Reglas de juego

- **Inicio**: título "ANUNNAKI TALES", "Mitos Interactivos", botón "Comenzar aventura" (va al Catálogo) y "Continuar partida" (solo si hay una partida guardada; ver abajo). Arriba a la derecha, ícono de perfil.
- **Catálogo** ("Elige tu aventura"): una tarjeta por aventura activa con título, subtítulo, dificultad con color y "~N turnos" (`estimated_turns`). Tocar una abre Elegir héroe.
- **Elegir héroe** ("Elige tu héroe"): grilla de 2 columnas con los héroes jugables de esa aventura (`is_playable`): avatar circular con la inicial, nombre, descripción corta (2 líneas) y barras de Fuerza / Sabiduría / Carisma (0–10). Si la aventura no tiene ninguno jugable, se muestra una sola tarjeta "Viajero" sin barras. Tocar uno lo marca; "Empezar" confirma y llama a `start` con el nombre del héroe (o "Viajero") como `player_name`. Mientras espera: "El narrador está preparando tu aventura…".
- **Gameplay**: título de la aventura, "Turno N" (`turn_count`), el texto de la escena, la tarjeta "Dato histórico" **solo si la respuesta trae `historical_fact`** (hoy no lo trae; ver "Abiertos"), y las tres opciones: punto de color de riesgo, texto, descripción y etiqueta ("Riesgo bajo / medio / alto"). Mientras la IA responde, las opciones se reemplazan por "El narrador está pensando…" con una barra indeterminada dorada. Debajo, "Elecciones gratis hoy: N de 3" (no se muestra a Premium). La flecha atrás vuelve a Inicio; la partida queda guardada.
- **Límite diario**: 3 elecciones gratis por día local (se reinicia a medianoche del teléfono). Empezar una aventura no cuenta; cada opción elegida **que la IA respondió bien** cuenta una (si la llamada falla, no se descuenta). Sin elecciones: tocar una opción abre el Paywall; si no compra, vuelve a la escena y puede seguir mañana. Premium: sin límite. Todo el cálculo en `choice_limit_rules.dart` (funciones puras con tests). Se guarda en el teléfono (`dailyChoicesUsed`, `lastChoiceDay` `yyyy-MM-dd`); se acepta que desinstalar reinicia el contador (limitación de v1).
- **Continuar partida**: la app guarda en el teléfono el `session_id` de la última partida con el título de la aventura, el nombre del héroe y el id del usuario. "Continuar partida" (visible solo si hay una guardada **del usuario que tiene la sesión abierta**) llama a `load` y abre Gameplay con esa escena, sin gastar IA ni elecciones. Si `load` responde 404, se borra lo guardado y se avisa "Esta partida ya no está disponible". Empezar una aventura nueva reemplaza la guardada. Recuperar partidas desde otro teléfono queda para después (hoy no hay forma de listar las partidas del usuario sin tocar el backend).
- **Fin de la aventura**: la función actual no termina las historias (ver "Abiertos"). Hasta que se agregue, el jugador sale cuando quiere con la flecha atrás y la partida queda para continuar.
- **Perfil**: correo del usuario, estado Premium ("Premium activo" o botón "Hazte Premium"), "Restaurar compras", "Privacidad de anuncios" (solo si UMP lo exige), "Política de privacidad" (abre el navegador), versión, "Cerrar sesión" y "Eliminar cuenta". Cerrar sesión borra la partida guardada del teléfono (el contador de elecciones del día se mantiene: es del teléfono, no de la cuenta).
- **Eliminar cuenta** (requisito de Apple y de Google): diálogo "¿Eliminar tu cuenta?" / "Se borrarán para siempre tu perfil, tus partidas y tu progreso. Esta acción no se puede deshacer. Si tienes Premium, cancela la suscripción desde Google Play o App Store: eliminar la cuenta no la cancela." / "Cancelar" / "Eliminar". Al confirmar: `delete-account`; si responde `deleted: true`, se cierra la sesión de RevenueCat y de Supabase, se borran los datos locales y se vuelve al ingreso; si falla: "No pudimos eliminar tu cuenta. Inténtalo de nuevo o escríbenos a fejcavallo@gmail.com".

## Cuentas

- La cuenta es obligatoria (la función de narrativa necesita el usuario). Pantalla de ingreso con dos pestañas, "Ingresar" y "Crear cuenta": correo, contraseña (y repetir contraseña al crear), "¿Olvidaste tu contraseña?" (manda el correo de Supabase). Errores traducidos a mensajes simples ("Correo o contraseña incorrectos", "Ese correo ya tiene cuenta", "Sin conexión").
- "¿Olvidaste tu contraseña?": pide el correo, Supabase manda un código de 6 dígitos, la app pide código y contraseña nueva (`verifyOTP` con tipo recovery y después `updateUser`).
- Con sesión guardada, la app abre directo en Inicio.
- Google (Android e iOS) llega en la iteración 11; Apple (solo iOS, obligatorio si hay Google) en la 13. Una cuenta de Google y una de Apple con el mismo correo pueden quedar unidas o separadas según Supabase; se acepta lo que haga Supabase por defecto.
- **Apple exige revocar el token de "Sign in with Apple" al eliminar la cuenta.** Con Supabase eso lo hace el backend: al eliminar una cuenta que entró con Apple, la app vuelve a pedir la credencial de Apple (como Ovun) y manda el `authorizationCode` a `delete-account`, que lo canjea y lo revoca con la clave de Apple antes de borrar al usuario (iteración 13). Sin esto no se manda la app a revisión de Apple.

## Premium (RevenueCat)

- Proyecto RevenueCat `72d974c7`. Clave pública de Android `goog_wuNZVNSPtgKsYMSKIlYjfnXuyQz`; la de iOS (`appl_...`) llega en la iteración 13. Entitlement **`premium`**. Offering `default` con los paquetes `$rc_monthly` (`anunnaki_premium_monthly`, base plan `monthly-plan`, USD 4,99) y `$rc_annual` (`anunnaki_premium_yearly`, base plan `yearly-plan`, USD 29,99).
- `Purchases.logIn(userId de Supabase)` al iniciar sesión y `Purchases.logOut()` al cerrarla o eliminar la cuenta: así el Premium sigue al usuario entre teléfonos.
- `purchases_flutter` cambió de forma entre versiones (`purchasePackage()` hoy devuelve un `PurchaseResult`; la app de FlutterFlow se rompió con eso). Para no depender de esa forma: después de comprar o restaurar, siempre `Purchases.getCustomerInfo()` y mirar `entitlements.all['premium']?.isActive`.
- **Paywall** ("Desbloquea el poder de los dioses"): beneficios **solo los que existen**: elecciones ilimitadas y sin anuncios (nada de "personajes exclusivos" ni "acceso anticipado" mientras no estén hechos: las tiendas rechazan promesas falsas); tarjeta mensual y anual (la anual destacada "Más popular"), **precios que devuelve la tienda** (no escritos a mano), "Restaurar compra", "Continuar gratis" y el texto legal de renovación automática. Al comprar o restaurar con éxito se cierra devolviendo `true`.
- Premium se lee al abrir la app y se escucha con `addCustomerInfoUpdateListener`.

## Anuncios (AdMob)

- Editor `pub-8769741188201469` (compartido con Ovun).
- Android: app `ca-app-pub-8769741188201469~9074937716`, banner `ca-app-pub-8769741188201469/8471468333`, intersticial `ca-app-pub-8769741188201469/2511863946`.
- iOS: app `ca-app-pub-8769741188201469~2296085996`, banner `ca-app-pub-8769741188201469/5604775611`, intersticial `ca-app-pub-8769741188201469/1635275865`.
- En debug (`kDebugMode`) las unidades pasan a las de prueba de Google: Android banner `ca-app-pub-3940256099942544/6300978111`, intersticial `ca-app-pub-3940256099942544/1033173712`; iOS banner `ca-app-pub-3940256099942544/2934735716`, intersticial `ca-app-pub-3940256099942544/4411468910`. El ID de app es siempre el real.
- **Consentimiento**: mensaje UMP "Anunnaki Tales consentimiento UE" (creado en AdMob → Privacidad y mensajería; **hay que publicarlo antes del release**). Se pide con `requestConsentInfoUpdate` + `loadAndShowConsentFormIfRequired` al abrir el Catálogo por primera vez, antes del primer anuncio; nunca durante la lectura. `MobileAds.instance.initialize()` una sola vez, cuando `canRequestAds` es verdadero. En debug, `ConsentDebugSettings` con geografía EEE para probar el formulario.
- **Banner** (320×50) solo para usuarios sin Premium, al pie de Catálogo y Elegir héroe. Nunca en Gameplay, Paywall ni Perfil. Si no carga, el espacio queda vacío.
- **Intersticial** solo para usuarios sin Premium: uno al empezar una aventura, después de tocar "Empezar" y antes de mostrar la primera escena (se precarga al entrar a Elegir héroe; si no está cargado, se sigue sin anuncio). Nunca entre opciones.
- Reglas en `ads_rules.dart` (funciones puras con tests). Sin conexión no hay anuncios y nada se rompe.

## Datos en shared_preferences

Una sola clave, `localData`: JSON con `schemaVersion` (1), `dailyChoicesUsed`, `lastChoiceDay` (`yyyy-MM-dd` local), `language` (`null` = el del teléfono) y `savedGame` (o `null`): `userId`, `sessionId`, `adventureId`, `mythId`, `adventureTitle`, `heroName`. Se guarda entero cada vez que cambia algo. Si no se puede leer, se descarta y se empieza de cero (no hay progreso valioso en el teléfono: las partidas viven en Supabase y el Premium en RevenueCat).

## Release

- **Firma.** Clave de subida registrada en Play Console: `upload-keystore-new.jks`, alias `upload` (RSA 2048). Se guarda en `C:\dev\keys\anunnaki-upload.jks`, fuera del repo, con respaldo fuera de la PC. `android/key.properties` (ignorado por git) tiene `storeFile`, `storePassword`, `keyAlias`, `keyPassword`; `android/key.properties.example` es la plantilla commiteada. Si falta `key.properties`, el build de release falla con un mensaje claro en vez de firmar con debug. **Nunca escribir la contraseña en este archivo ni en el repo.**
- **Versión.** `version` en `pubspec.yaml`: la parte antes del `+` es la visible; la de después es el versionCode y se incrementa en cada subida (el primero de este proyecto es 12).
- **Build.** `flutter build appbundle --release` en la PC; el `.aab` se sube a mano a Play Console → Prueba cerrada (Alpha). R8 activado, con las reglas que pidan RevenueCat y AdMob.
- **Ícono y splash.** `flutter_launcher_icons` y `flutter_native_splash` desde `assets/icon/icon.png` (fondo `#0A0E1A`; el PNG tiene canal alfa, así que para iOS va `remove_alpha_ios: true`, porque la App Store rechaza íconos con transparencia). Regenerar el splash puede reescribir `AndroidManifest.xml`: revisar después que siga `android:screenOrientation="portrait"` y `android:label="Anunnaki Tales"`.
- **Manifest de release.** `INTERNET` y `com.google.android.gms.permission.AD_ID` declarados explícitamente; meta-data `com.google.android.gms.ads.APPLICATION_ID` con el ID real.
- **iOS.** `codemagic.yaml` con dos workflows, copiando la estructura y los nombres del de Ovun: `ios-check` (sin firma, solo verifica que compile) y el de release (firma con la integración de App Store Connect de Codemagic y sube a TestFlight). `Info.plist`: `GADApplicationIdentifier`, `SKAdNetworkItems` de Google, `NSUserTrackingUsageDescription` (ATT), `UIRequiresFullScreen`, solo vertical; desde la iteración 11, `GIDClientID` y el esquema de URL con el client ID invertido que pide Google.
- **Prueba de release en el emulador.** El emulador cuenta como dispositivo de prueba de AdMob. En un teléfono propio, registrarlo como dispositivo de prueba antes de abrir un build de release.
- Receta completa en `docs/release.md` (iteración 10).

## Cómo trabajar

- Una tarea por pedido. Antes de dar algo por terminado: `flutter analyze` sin warnings y `flutter test` en verde. Si tocaste una pantalla, pedile a Federico que la mire en el emulador y esperá su feedback antes de seguir.
- Commits chicos y descriptivos en español. Hacé el commit al cerrar cada tarea.
- Código en inglés (nombres de clases, variables, archivos). Comentarios y mensajes de commit en español. Textos de interfaz en los ARB.
- Los textos de interfaz en español van en **español neutro (tú)**, igual que la app publicada ("Elige tu aventura", "Hazte Premium"): nada de voseo. Los comentarios y commits siguen en el español de Federico.
- Al terminar una tarea, resumí en 3–5 líneas qué archivos creaste y qué hace cada uno, sin jerga.
- Si una regla de este archivo se contradice con lo que Federico pide, señalalo antes de implementar.
- No refactorices lo que no te pidieron. No agregues abstracciones "por si acaso".
- Toda pantalla tiene una forma clara de volver (flecha atrás), salvo el ingreso y la de fin de aventura.
- No se modifica nada del backend (tablas, funciones, reglas) desde este repo sin preguntar: la app publicada (Build 11) usa el mismo backend hasta que el Build 12 la reemplace.
- Cuando se cambie una regla de juego, se actualizan en el mismo pedido este archivo, los textos en los dos idiomas y los tests.

## Fases

0. **Preparación** (Federico, sin código): repo y carpeta, `flutter create`, este archivo, `docs/plan-migracion.md` y las dos Edge Functions en `supabase/functions/`, clave de subida en `C:\dev\keys\`, fuentes en `assets/fonts/`, ícono.
1. **App jugable en Android** (iteraciones 1–7): base y tema, ingreso con email, Inicio y Catálogo, Elegir héroe, Gameplay con límite diario, Continuar partida, Perfil con eliminar cuenta.
2. **Monetización** (8–9): Premium con RevenueCat, AdMob con consentimiento.
3. **Publicación Android** (10): firma, ícono, splash, versión 1.1.0+12, subida a la prueba cerrada.
4. **Login social e iOS** (11–13): Google, iOS base con Codemagic, Apple + revocación del token al eliminar la cuenta + TestFlight.
5. **Backend** (14–15, con OK de Federico, después del Build 12): narrador con dato histórico y final de aventura; función `narrative` que toma el usuario del JWT.

## Abiertos (preguntar antes de asumir)

- ¿Las aventuras con `is_free = false` se bloquean para usuarios sin Premium (candado y Paywall), o todas siguen abiertas como en la app publicada? Hasta que Federico decida: todas abiertas.
- ¿Los héroes con `is_premium = true` se bloquean para usuarios sin Premium? Hasta que decida: todos abiertos.
- **Final de aventura y dato histórico** (iteración 14): propuesta, cambiar el prompt de `narrative` para que vuelva a devolver `historical_fact` y, cuando `turn_count` llega a los turnos estimados de la aventura, escriba un cierre con `is_final: true` y sin opciones (la app mostraría "Fin de la aventura" con "Otra aventura" e "Inicio"). Es un cambio del backend: se hace con OK de Federico.
- **Seguridad de `narrative`** (iteración 15): hoy confía en el `user_id` que manda la app y no revisa que la partida sea del que llama; cualquiera con la anon key puede gastar IA. Propuesta: tomar el usuario del JWT (como `delete-account`), ignorar el `user_id` del body y rechazar partidas ajenas. El límite de 3 elecciones también vive solo en el teléfono; llevarlo al servidor es opcional.
