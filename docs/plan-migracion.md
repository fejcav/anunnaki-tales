# Anunnaki Tales — plan de migración a Flutter puro

Versión 1 · 30 de septiembre de 2026. Acompaña a `CLAUDE.md` (las reglas están allá; acá está el orden de trabajo).

## Qué cambia y qué no

- **Sigue igual (no se toca):** Supabase entero (base, login, `narrative`, `delete-account`), RevenueCat (productos, entitlement `premium`), IDs de AdMob, ficha y prueba cerrada de Play Console, package `com.mycompany.anunnakitales`, clave de subida `upload-keystore-new.jks`, páginas legales, cuenta de Apple Developer (la misma de Ovun).
- **Se rehace:** la app, como proyecto Flutter normal en `C:\dev\anunnaki-tales`, trabajado con Claude Code igual que Ovun.
- **Costo:** cero nuevo. Flutter y Claude Code en tu PC; Android se compila en tu PC; iOS en Codemagic con los 500 minutos gratis por mes de macOS (compartidos con Ovun). FlutterFlow deja de usarse.
- **El primer build del proyecto nuevo es el 12** (versión 1.1.0+12) y reemplaza al 11 en la prueba cerrada.

## Cómo usar este plan

Una iteración por vez. Para cada una: si tiene "Antes (vos)", hacé esos pasos; después pegá el pedido en Claude Code dentro de `C:\dev\anunnaki-tales`; al final probá lo de "Probá" en el emulador y recién ahí pasá a la siguiente. Si algo no anda, se lo contás a Claude Code en el mismo chat antes de seguir.

---

## Iteración 0 — Preparación (vos, ~30 min, sin código)

1. En una terminal, dentro de `C:\dev`:
   `flutter create --org com.mycompany --project-name anunnakitales --platforms android,ios anunnaki-tales`
2. Copiá a `C:\dev\anunnaki-tales` lo que viene en el paquete de esta sesión, respetando las carpetas:
   - `CLAUDE.md` (en la raíz)
   - `docs\plan-migracion.md` (este archivo)
   - `supabase\functions\narrative\index.ts` y `supabase\functions\delete-account\index.ts`
   - `assets\icon\icon.png` (el ícono de la tienda, 1024×1024)
3. Buscá `upload-keystore-new.jks` (está en la carpeta del proyecto "Anunnaki Tales" de tu PC) y copialo a `C:\dev\keys\anunnaki-upload.jks`. Guardá una copia fuera de la PC (Drive, pendrive). La contraseña **no** va en ningún archivo del repo.
4. Fuentes: en fonts.google.com bajá las familias **Cinzel**, **Lora** e **Inter** ("Download family"). De cada ZIP copiá a `C:\dev\anunnaki-tales\assets\fonts\` los archivos de la carpeta `static` (Cinzel-Regular/SemiBold/Bold, Lora-Regular/Italic/SemiBold, Inter-Regular/Medium/SemiBold/Bold; en Inter, los que no dicen "18pt" o "24pt" en el nombre, o los de "18pt" si solo hay esos) y el `OFL.txt` de cada una con otro nombre (`OFL-Cinzel.txt`, etc.).
5. Corré `flutter doctor -v` y confirmá que el Android SDK que usa es `C:\Users\fedec\AppData\Local\Android\Sdk` (el de Ovun). El emulador de la app vieja (`TestDevice` en `C:\android-sdk`) ya no se usa.
6. Arrancá el emulador Pixel 8 (`flutter emulators --launch Pixel_8`) para tenerlo listo.

---

## Iteración 1 — Base del proyecto

**Pedido para Claude Code:**

```
Iteración 1 — Base del proyecto. Leé CLAUDE.md completo antes de empezar.
1. Git: el remoto https://github.com/fejcav/anunnaki-tales tiene en main solo un commit con un README, y flutter create hizo otro README. Hacé: git init -b main, commit inicial de todo, git remote add origin <url>, git fetch origin, git merge origin/main --allow-unrelated-histories -X ours (queda nuestro README) y git push -u origin main. Nada de force push. La rama flutterflow es el código viejo: no la toques, pero podés leerla con git show origin/flutterflow:lib/backend/supabase/supabase.dart para copiar la URL y la anon key de Supabase.
2. pubspec: agregá solo provider, supabase_flutter, shared_preferences, flutter_localizations, intl, flutter_animate, url_launcher, package_info_plus. version: 1.1.0+12.
3. Fuentes: ya están en assets/fonts/ (TTF estáticos de Cinzel, Lora e Inter con sus licencias). Declaralas en el pubspec con sus pesos. Si falta alguna, frená y decime cuál.
4. lib/config.dart con la URL y anon key de Supabase. lib/app_theme.dart con los colores y estilos de "Aspecto". l10n en español e inglés (ARB) con los textos que uses.
5. main.dart: Supabase.initialize, solo vertical, tema oscuro, rutas con pantallas vacías para auth, home, catalog, hero_select, gameplay, paywall y profile (cada una con su título y flecha atrás). Widget StarsBackground.
6. AndroidManifest: android:label="Anunnaki Tales", screenOrientation portrait, permiso INTERNET.
Al terminar: flutter analyze sin warnings, commit "Base del proyecto: tema, fuentes, l10n y rutas" y push.
```

**Probá:** `flutter run -d emulator-5554` abre una pantalla oscura con título dorado en Cinzel; el teléfono en horizontal no rota.

---

## Iteración 2 — Ingreso con email

**Antes:** ~~Supabase → Authentication → Emails → plantilla "Reset Password": agregar el código con `{{ .Token }}`.~~ Hecho el 30/09 (asunto y texto en español con el código grande, el enlace de siempre y el código en inglés al pie). El código tiene 6 dígitos ("Email OTP length" = 6 en Supabase).

```
Iteración 2 — Ingreso con email (ver "Cuentas" en CLAUDE.md). Creá services/auth_service.dart (única clase que toca Supabase Auth) y la pantalla de ingreso con pestañas "Ingresar" y "Crear cuenta": correo, contraseña (Supabase pide mínimo 6 caracteres), repetir contraseña al crear. "¿Olvidaste tu contraseña?" con el código de 6 dígitos que llega por mail (el campo acepta de 6 a 10): resetPasswordForEmail, pantalla para el código y la contraseña nueva, verifyOTP con tipo recovery y después updateUser. Mensajes de error simples y traducidos. Con sesión guardada la app abre en Inicio; sin sesión, en ingreso. Commit al terminar.
```

**Probá:** crear una cuenta nueva con un correo tuyo, cerrar la app, volver a abrirla (tiene que entrar directo), el mensaje de error con una contraseña mal puesta, y el cambio de contraseña con el código que llega por mail (el correo de Supabase manda como máximo 2 por hora). Tu cuenta vieja de la app de FlutterFlow también tiene que funcionar (es el mismo Supabase).

---

## Iteración 3 — Inicio y Catálogo

```
Iteración 3 — Inicio y Catálogo (ver "Reglas de juego"). Inicio: título, "Mitos Interactivos", "Comenzar aventura" y el ícono de perfil (lleva a la pantalla vacía de Perfil); "Continuar partida" todavía no. services/story_api.dart (única clase que lee tablas de Supabase y llama a narrative) con fetchAdventures(). Catálogo con AdventureCard: título y subtítulo en el idioma activo, dificultad con color y "~N turnos". Estados de carga, error con "Reintentar" y vacío. El color y la etiqueta de dificultad van en lib/logic/risk_rules.dart con test. Commit al terminar.
```

**Probá:** el Catálogo muestra los 10 mitos en orden; con el emulador en modo avión aparece el error con "Reintentar".

---

## Iteración 4 — Elegir héroe y empezar la aventura

```
Iteración 4 — Elegir héroe y empezar (ver "Reglas de juego" y "Backend"). fetchHeroes(adventureId) con select('*, characters(*)'), solo los is_playable; si no queda ninguno, una tarjeta "Viajero". Grilla de 2 columnas con HeroCard: avatar con la inicial, nombre, descripción corta y barras de Fuerza/Sabiduría/Carisma. Tocar marca, "Empezar" llama a narrative con action start y user_id del usuario logueado (sin user_id la partida no se guarda). Mientras espera: "El narrador está preparando tu aventura…". Si la respuesta trae session_id: guardá savedGame (con el userId) en data/local_store.dart y abrí Gameplay con la escena (por ahora Gameplay solo muestra el texto). Si no trae session_id o falla: aviso con Reintentar y no se guarda nada. Commit al terminar.
```

**Probá:** elegir Gilgamesh en "El Hombre Salvaje de Uruk" y ver la primera escena. En Supabase → Table Editor → game_sessions tiene que aparecer una fila nueva con tu user_id.

---

## Iteración 5 — Gameplay y límite diario

```
Iteración 5 — Gameplay y límite diario (ver "Reglas de juego"). Pantalla completa de Gameplay: título, "Turno N", texto de la escena en Lora, tarjeta "Dato histórico" solo si viene historical_fact, y las tres opciones con ChoiceButton (punto de color, texto, descripción, etiqueta de riesgo; colores en lib/logic/risk_rules.dart con test). Elegir llama a narrative con action continue, session_id y choice_id numérico; mientras tanto "El narrador está pensando…" con barra dorada. lib/logic/choice_limit_rules.dart con funciones puras y tests: 3 por día local, se descuenta solo si la respuesta fue buena, reinicio a medianoche. "Elecciones gratis hoy: N de 3". Sin elecciones, tocar una opción abre la pantalla de Paywall (todavía vacía, con un texto "Premium llega pronto" y "Volver"). Premium todavía no existe: todos son gratis. Commit al terminar.
```

**Probá:** jugar 3 elecciones seguidas (cada una cambia la historia y sube el turno); la cuarta abre el Paywall. Con modo avión en medio de una elección: aviso y la elección no se descuenta.

---

## Iteración 6 — Continuar partida

```
Iteración 6 — Continuar partida (ver "Reglas de juego"). En Inicio, "Continuar partida" visible solo si hay savedGame del usuario con sesión abierta (mismo userId), con el título de la aventura y el nombre del héroe. Llama a narrative con action load y abre Gameplay con esa escena sin descontar elecciones. 404: borrá savedGame y avisá "Esta partida ya no está disponible". Empezar otra aventura reemplaza la guardada. Commit al terminar.
```

**Probá:** jugar dos turnos, cerrar la app del todo, abrirla y tocar "Continuar partida": tiene que aparecer la misma escena y el mismo turno.

---

## Iteración 7 — Perfil y eliminar cuenta

```
Iteración 7 — Perfil (ver "Reglas de juego" → Perfil y Eliminar cuenta). Correo, "Política de privacidad" (abre el navegador), versión con package_info_plus, "Cerrar sesión" (borra la partida guardada del teléfono) y "Eliminar cuenta" con el diálogo y los textos exactos de CLAUDE.md; al confirmar, functions.invoke('delete-account') en auth_service; si responde deleted: true, cerrar sesión, borrar localData y volver al ingreso; si no, el aviso de error. Premium, Restaurar compras y Privacidad de anuncios llegan en las iteraciones 8 y 9. Commit al terminar.
```

**Probá:** crear una cuenta de prueba, jugar un turno, eliminarla. En Supabase → Authentication → Users ya no tiene que estar, y su fila de game_sessions tampoco. Con tu cuenta real, "Cerrar sesión" y volver a entrar.

**Punto de control:** acá la app ya es jugable de punta a punta. Recorrela entera antes de seguir.

---

## Iteración 8 — Premium con RevenueCat

**Antes (vos):** nada; la configuración de RevenueCat y de Play ya existe.

```
Iteración 8 — Premium con RevenueCat (ver "Premium"). Agregá purchases_flutter. services/purchases.dart (única clase que lo toca): configurar con la clave de Android de CLAUDE.md, logIn con el id de Supabase al iniciar sesión y logOut al cerrar o eliminar la cuenta, leer y escuchar el entitlement premium. Después de comprar o restaurar, siempre getCustomerInfo() y mirar el entitlement (no dependas de lo que devuelve purchasePackage: cambió entre versiones). Paywall completo con los precios que devuelve la tienda para $rc_monthly y $rc_annual, y solo los beneficios que existen (elecciones ilimitadas, sin anuncios). En Perfil: "Premium activo" o "Hazte Premium", y "Restaurar compras". Premium no tiene límite de elecciones y no ve el contador. Commit al terminar.
```

**Probá** (como en Ovun, con el emulador logueado con fejcavallo@gmail.com, que es license tester): comprar el mensual de prueba, ver "Premium activo" y elegir más de 3 veces; cerrar sesión y volver a entrar sigue Premium. Cancelá la suscripción de prueba desde Play Store al terminar.

---

## Iteración 9 — Anuncios con consentimiento

**Antes (vos o yo en una sesión con tu navegador):** en AdMob → Privacidad y mensajería → Reglamentos europeos, publicar el mensaje "Anunnaki Tales consentimiento UE" (hoy está en borrador).

```
Iteración 9 — AdMob con consentimiento (ver "Anuncios"). Agregá google_mobile_ads. meta-data del ID de app de Android en el manifest y permiso com.google.android.gms.permission.AD_ID. services/ads.dart (única clase que toca el SDK): consentimiento UMP al abrir el Catálogo por primera vez, initialize una sola vez cuando canRequestAds, banner al pie de Catálogo y Elegir héroe, intersticial al empezar una aventura (precargado al entrar a Elegir héroe; si no está listo, se sigue sin anuncio). Nada de eso para Premium. Unidades de prueba de Google en debug. lib/logic/ads_rules.dart con tests. En Perfil, "Privacidad de anuncios" solo si privacyOptionsRequirementStatus es required. Commit al terminar.
```

**Probá:** en debug aparece el formulario de consentimiento (con geografía EEE forzada), el banner de prueba en Catálogo y el intersticial de prueba al tocar "Empezar". Con la cuenta Premium no aparece ninguno.

---

## Iteración 10 — Release de Android (Build 12)

**Antes (vos):** crear `android\key.properties` a partir de la plantilla que deja Claude Code, con `storeFile=C:\\dev\\keys\\anunnaki-upload.jks`, `keyAlias=upload` y la contraseña.

```
Iteración 10 — Release de Android (ver "Release"). Firma de release leyendo android/key.properties (ignorado por git) con plantilla key.properties.example; si falta, que el build falle con un mensaje claro. Ícono adaptativo y splash con flutter_launcher_icons y flutter_native_splash desde assets/icon/icon.png, fondo #0A0E1A (revisá el manifest después: portrait y label). R8 con las reglas que pidan RevenueCat y AdMob. Permisos INTERNET y AD_ID explícitos. Verificá version 1.1.0+12. Generá el appbundle y un APK de release para probar en el emulador. Escribí docs/release.md con la receta paso a paso para las próximas subidas. Commit al terminar.
```

**Probá:** instalar el APK de release en el emulador: ícono, splash, ingreso, una aventura, compra y anuncios (el emulador es dispositivo de prueba de AdMob).

**Después (vos):** Play Console → Anunnaki Tales → Prueba cerrada (Alpha) → Crear versión → subir `build\app\outputs\bundle\release\app-release.aab` → notas "Nueva versión: eliminar cuenta, consentimiento de anuncios, mejoras" → revisar y lanzar. Los 14 días de prueba cerrada empiezan a contar cuando hay 12 testers que aceptaron la invitación (hoy hay 1): conviene invitarlos con este build.

---

## Iteración 11 — Ingreso con Google

**Antes (vos, o yo con tu navegador):**
1. Google Cloud, proyecto `anunnaki-tales` → APIs y servicios → Credenciales: crear un cliente OAuth **Web**, **tres Android** (cada uno lleva una sola SHA-1: la de la clave de subida, la de firma de apps de Play Console → Integridad de la app y la de debug del emulador; package `com.mycompany.anunnakitales`) y uno **iOS** (bundle `com.mycompany.anunnakitales`).
2. Supabase → Authentication → Providers → Google: activarlo y cargar los Client IDs (el Web primero, después el de iOS).

```
Iteración 11 — Ingreso con Google (ver "Cuentas"). Agregá google_sign_in. Botón "Continuar con Google" en la pantalla de ingreso (Android e iOS); con el idToken de Google llamá a signInWithIdToken(provider: OAuthProvider.google) en auth_service. Client ID Web e iOS en config.dart; en ios/Runner/Info.plist, GIDClientID y el esquema de URL con el client ID de iOS invertido. Seguí la documentación actual de google_sign_in y de Supabase para login nativo. Commit al terminar.
```

**Probá:** entrar con Google en el emulador; en Supabase aparece el usuario con proveedor Google.

---

## Iteración 12 — iOS base y Codemagic

**Antes (vos):** en Codemagic (la misma cuenta de Ovun) agregar la app desde el repo `fejcav/anunnaki-tales`.

```
Iteración 12 — iOS base (ver "Release" → iOS). Info.plist: GADApplicationIdentifier con el ID de iOS, SKAdNetworkItems de Google, NSUserTrackingUsageDescription, UIRequiresFullScreen y solo vertical; versión mínima de iOS la que pidan los paquetes. IDs de AdMob y clave de RevenueCat por plataforma en config.dart (la de iOS queda vacía hasta la 13, y sin clave no se configura RevenueCat en iOS). codemagic.yaml con el workflow ios-check (sin firma), copiando la estructura y los nombres del codemagic.yaml de Ovun (pedime que te lo pase si no lo tenés a mano). Commit al terminar.
```

**Probá:** correr `ios-check` en Codemagic y que termine en verde (gasta unos 15–20 de los 500 minutos del mes).

---

## Iteración 13 — Apple, App Store y TestFlight

**Antes (vos, o yo con tu navegador):**
1. Apple Developer → Identifiers: registrar `com.mycompany.anunnakitales` con **Sign in with Apple** e **In-App Purchase**.
2. App Store Connect: crear la app "Anunnaki Tales" con ese bundle; crear el grupo de suscripciones "Anunnaki Premium" con `anunnaki_premium_monthly` (1 mes, USD 4,99) y `anunnaki_premium_yearly` (1 año, USD 29,99).
3. RevenueCat: agregar la app de App Store, subir la clave P8 de App Store Connect, importar los productos al entitlement `premium` y al offering `default`; copiar la clave pública `appl_...`.
4. Supabase → Authentication → Providers → Apple: activarlo con el bundle ID como Client ID.
5. Codemagic: integración con App Store Connect (la misma de Ovun sirve).
6. AdMob → Privacidad y mensajería → IDFA: crear el mensaje explicativo de seguimiento para iOS (así UMP pide el permiso ATT sin paquete extra).
7. Para revocar el token al eliminar la cuenta: Apple Developer → Keys → crear una clave con **Sign in with Apple** (se baja un `.p8` una sola vez; guardalo con la clave de subida). En Supabase → Edge Functions → Secrets cargar `APPLE_TEAM_ID` (`Y7TN232MXN`), `APPLE_KEY_ID`, `APPLE_CLIENT_ID` (`com.mycompany.anunnakitales`) y `APPLE_PRIVATE_KEY` (el contenido del `.p8`).

```
Iteración 13 — Sign in with Apple, revocación y TestFlight (ver "Cuentas" y "Release"). Agregá sign_in_with_apple y crypto. Botón "Continuar con Apple" solo en iOS y arriba del de Google; nonce aleatorio, hash SHA-256 para Apple y el nonce crudo a signInWithIdToken(provider: OAuthProvider.apple). Eliminar cuenta con proveedor Apple: la app pide de nuevo la credencial de Apple y manda el authorizationCode a delete-account; actualizá supabase/functions/delete-account/index.ts para que, si llega ese código, arme el client secret (JWT ES256 con los secrets de Apple), lo canjee en https://appleid.apple.com/auth/token y revoque el token en https://appleid.apple.com/auth/revoke antes de borrar al usuario; si la revocación falla, no borra nada. Sin código, sigue funcionando igual que hoy. Pasame el archivo para desplegarlo desde el dashboard. Clave appl_ de RevenueCat en config.dart. Workflow de release en codemagic.yaml que firma y sube a TestFlight, como en Ovun. Commit al terminar.
```

**Probá:** instalar desde TestFlight en un iPhone: ingreso con Apple, una aventura, compra de prueba (sandbox) y eliminar cuenta (después, en Ajustes del iPhone → Apple ID → Iniciar sesión con Apple, Anunnaki Tales ya no tiene que figurar). Recién con esto se manda a revisión de Apple.

---

## Iteración 14 — Narrador: dato histórico y final (backend, con tu OK)

Se hace **después** de que el Build 12 reemplace al 11. Cambia el prompt de `narrative` para que:
- vuelva a devolver `historical_fact` (1–2 oraciones reales por escena);
- reciba los turnos estimados de la aventura y, al llegar, escriba un cierre con `is_final: true` y sin opciones.

En la app: tarjeta "Dato histórico" (ya preparada) y pantalla "Fin de la aventura" con "Otra aventura" e "Inicio". El código se edita en `supabase/functions/narrative/index.ts` y se despliega pegándolo en el editor del dashboard de Supabase.

---

## Iteración 15 — Seguridad del backend (con tu OK)

- `narrative` toma el usuario del JWT (como `delete-account`), ignora el `user_id` del body y rechaza partidas de otro usuario. La app ya manda el JWT, así que no hace falta cambiarla.
- Opcional: llevar el límite de 3 elecciones diarias al servidor (hoy vive solo en el teléfono).
