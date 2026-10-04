# Anunnaki Tales — plan de migración, versión 2

Versión 2 · 2 de octubre de 2026. Reemplaza a la versión 1 desde la iteración 9 (la decisión está en `docs/cambio-de-rumbo.md`). Las iteraciones 0 a 7 ya están hechas; la 8 (Premium con RevenueCat) queda reemplazada por la 11.

## Cómo usar este plan

Una iteración por vez. Para cada una: si tiene "Antes", hacé esos pasos; después abrí Claude Code (PowerShell → `cd C:\dev\anunnaki-tales` → `claude` → `/clear`) y pegá el pedido. Al final, Claude Code prueba en el emulador y te pasa un resumen; si algo no anda, se lo contás en el mismo chat antes de seguir.

Todos los pedidos incluyen la línea de **Entorno**, que remite a las reglas de `CLAUDE.md`: emulador propio `Anunnaki_Pixel_8` en el puerto 5560 (arranque en frío con `-no-snapshot`, a propósito, para ahorrar disco), nunca `Pixel_8`; no compilar ni abrir el emulador mientras Ovun trabaja; al menos 15 GB libres; al terminar, cerrar emulador, Gradle, `flutter run` y logcat.

## Contenido (en paralelo, Cowork + Federico)

Cada historia se escribe en el proyecto de claude.ai, una por vez: Cowork la escribe en español con su demo jugable, Federico la lee y aprueba, Cowork hace el inglés y la entrega validada. Para sumarla a la app alcanza con este pedido corto:

```
Contenido — agregar la historia <id>. Entorno: reglas de CLAUDE.md. Copiá el archivo <id>.json que te paso a assets/data/stories/, corré flutter test (la validación tiene que pasar) y abrí la aventura en el emulador hasta un final. No cambies el texto: si la validación falla, decime qué regla y en qué escena. Commit "Historia: <título>" y push.
```

Orden sugerido: las 3 gratis primero (Gilgamesh y Enkidu ✍️ piloto listo en español, Inanna, Lugalbanda), después las 7 de la compra.

---

## Iteración 9 — Historias locales

**Antes (Federico o Cowork):** que estén en el repo `docs/cambio-de-rumbo.md`, `docs/formato-historias.md`, `docs/plan-migracion-v2.md` y `assets/data/stories/gilgamesh_enkidu.json` (Cowork los deja en la carpeta si está conectada; si no, se bajan del chat).

```
Iteración 9 — Historias locales. Entorno: reglas de CLAUDE.md (Anunnaki_Pixel_8 en emulator-5560 con -no-snapshot; nada si Ovun está compilando; mínimo 15 GB libres; al terminar, cerrar emulador, Gradle, flutter run y logcat).
Leé primero docs/cambio-de-rumbo.md y docs/formato-historias.md: la app deja la IA en vivo y pasa a historias escritas de antemano, sin servidor ni cuenta y con compra única. En esta iteración el juego pasa a funcionar con historias locales; la cuenta y RevenueCat se quitan en la 10.
1. Documentos: reemplazá docs/plan-migracion.md por el contenido de docs/plan-migracion-v2.md (y borrá el -v2) y actualizá CLAUDE.md con la sección "Reglas nuevas para CLAUDE.md" de docs/cambio-de-rumbo.md, conservando lo que esa sección no toca (Entorno, Aspecto, Cómo trabajar, emulador y Ovun).
2. Catálogo local: generá una sola vez assets/data/catalog.json leyendo la tabla adventures de Supabase con la anon key (lectura pública, GET a /rest/v1/adventures?is_active=eq.true&order=sort_order): id, sortOrder, difficulty, isFree, title/subtitle/description {es, en}. Desde ahora la app no lee el catálogo de Supabase.
3. Modelos (LocalizedText con fallback al español si falta el inglés, Adventure, Story, StoryScene, StoryChoice, StoryEnding), services/story_repository.dart (ÚNICA clase que lee assets/data: catálogo e historias; una aventura sin archivo devuelve null) y lib/logic/story_rules.dart con funciones puras: validar una historia con todas las reglas de docs/formato-historias.md (modo normal y estricto), escena siguiente, si es final, finales de una historia y camino más corto hasta el final del mito.
4. Tests: test/story_validation_test.dart valida todos los archivos de assets/data/stories/ (modo normal; el estricto queda listo para el release) y test/story_rules_test.dart cubre las funciones, incluido un caso que falla primero (historia con un ciclo, una opción que apunta a una escena inexistente, una escena inalcanzable, voseo).
5. Pantallas: Catálogo desde el catálogo local, con "~N escenas" calculado de la historia, "Finales: N de M" si hay descubiertos y "Próximamente" (no se abre) si no hay historia; por ahora todas las aventuras con historia están abiertas. "Elige tu héroe" pasa a "Tu héroe" (screens/hero_intro): nombre y descripción del protagonista, descripción de la aventura y "Empezar". Gameplay: "Capítulo N · Título", "Turno N", párrafos separados por línea en blanco, "Dato histórico" si hay, opciones con ChoiceButton (sin punto ni etiqueta si la opción no tiene risk). Pantalla de Final (screens/ending) como dice CLAUDE.md, con "Volver a la última decisión" solo en finales trágicos.
6. Guardado: localData schemaVersion 2 (savedGame con adventureId, sceneId y path; endingsFound por aventura). Al leer la versión 1 se descarta la partida vieja y el contador de elecciones. "Continuar partida" en Inicio solo si la historia y la escena guardadas existen. Al llegar a un final se guarda como descubierto y se borra la partida.
7. Sacá el límite diario (choice_limit_rules.dart, sus tests, el contador "Elecciones gratis hoy") y story_api.dart (ya no se llama a la función narrative). La cuenta y RevenueCat siguen hasta la iteración 10: no los toques todavía.
Probá en el emulador (con una cuenta de prueba, que después eliminás): jugar el piloto hasta el final del mito y hasta un final trágico (probando "Volver a la última decisión"); cerrar la app a mitad de camino y "Continuar partida"; "Finales: N de M" en el catálogo; las otras aventuras en "Próximamente". Revisá los textos en español.
Al terminar: flutter analyze sin warnings, tests en verde, commits chicos y push. Resumime qué archivos creaste o borraste y qué hace cada uno.
```

**Probá vos:** jugá el piloto en el emulador como lo vas a ver en el teléfono.

---

## Iteración 10 — Sin cuenta ni servidor

```
Iteración 10 — Sin cuenta ni servidor. Entorno: reglas de CLAUDE.md.
Según docs/cambio-de-rumbo.md, la app ya no tiene cuenta ni usa Supabase ni RevenueCat:
1. Sacá la pantalla de ingreso, auth_service.dart, la eliminación de cuenta, purchases.dart (RevenueCat) y los paquetes supabase_flutter y purchases_flutter; la URL, la anon key y las claves de RevenueCat salen de config.dart. Borrá la carpeta supabase/ del repo (las funciones quedan en el historial de git y en el respaldo del proyecto de claude.ai).
2. La app abre directo en Inicio. Perfil pasa a Ajustes (screens/settings): "Política de privacidad", "Borrar progreso" (confirmación dentro de la pantalla, sin diálogos del sistema: borra partida guardada y finales descubiertos) y la versión. El Paywall de la iteración 8 se quita; vuelve en la 11.
3. Revisá que no quede ninguna referencia a Supabase, RevenueCat, user_id, sesión ni eliminar cuenta (código, ARB, CLAUDE.md, README) y que el AndroidManifest no pida permisos que ya no se usan.
Probá en el emulador: instalar limpio (desinstalá la versión anterior), abrir, jugar, "Borrar progreso". Al terminar: analyze, tests, commit y push. Resumen corto.
```

---

## Iteración 11 — Compra única

**Antes (Federico, o Cowork con tu Chrome y tu OK):** en Play Console → Anunnaki Tales → Monetizar → Productos → Productos únicos (in-app): crear `anunnaki_completo`, nombre "Anunnaki Tales completo", descripción "Desbloquea todos los mitos y quita los anuncios. Pago único.", precio (sugerido USD 3,99) y activarlo. Para probar, `fejcavallo@gmail.com` ya es license tester y está logueado en Play Store en el emulador.

```
Iteración 11 — Compra única. Entorno: reglas de CLAUDE.md.
Agregá in_app_purchase e in_app_purchase_android. Tomá como referencia, SOLO DE LECTURA, cómo lo resolvió Ovun en C:\dev\ovun\lib\services\purchases.dart y lib\logic\purchase_rules.dart (con sus tests); no modifiques nada de Ovun.
1. services/purchases.dart (ÚNICA clase que toca in_app_purchase): disponibilidad, precio de anunnaki_completo, comprar, escuchar purchaseStream, completar y reconocer compras, restaurar. lib/logic/purchase_rules.dart con funciones puras y tests: qué hacer con cada evento (comprado, restaurado, pendiente, error, cancelado) y qué aventuras están abiertas (isFree o compra hecha). El estado se guarda en localData.purchased para arrancar sin esperar a la tienda.
2. Catálogo: las aventuras no gratis y con historia muestran candado si no hay compra; tocarlas abre el Paywall ("Desbloquea todos los mitos"): beneficios reales (cuántas aventuras ya escritas desbloquea, sin anuncios, pago único sin suscripción), precio de la tienda, "Comprar", "Restaurar compra", "Ahora no". Al comprar o restaurar, se cierra y se abre la aventura.
3. Ajustes: "Desbloquear todo" o "Todo desbloqueado" y "Restaurar compra".
Probá en el emulador con fejcavallo@gmail.com: comprar con la tarjeta de prueba, ver todo abierto, borrar los datos de la app (adb shell pm clear) y "Restaurar compra". Al terminar, reembolsá o cancelá la compra de prueba desde Play Console si hace falta repetirla. Analyze, tests, commit y push.
```

---

## Iteración 12 — Anuncios con consentimiento

El mensaje RGPD "Anunnaki Tales consentimiento UE" ya está publicado en AdMob.

```
Iteración 12 — AdMob con consentimiento. Entorno: reglas de CLAUDE.md.
Agregá google_mobile_ads (podés mirar, SOLO DE LECTURA, C:\dev\ovun\lib\services\ads.dart y ads_rules.dart). meta-data del ID de app de Android en el manifest y permiso com.google.android.gms.permission.AD_ID. services/ads.dart (ÚNICA clase que toca el SDK): consentimiento UMP al abrir el Catálogo por primera vez, initialize una sola vez cuando canRequestAds, banner al pie de Catálogo y Tu héroe, intersticial al tocar "Empezar" (precargado al entrar a Tu héroe; si no está listo, se sigue sin anuncio). Nada de eso con la compra hecha. Unidades de prueba de Google en debug. lib/logic/ads_rules.dart con tests. En Ajustes, "Privacidad de anuncios" solo si privacyOptionsRequirementStatus es required.
Probá: formulario de consentimiento (geografía EEE forzada en debug), banner y intersticial de prueba; con la compra hecha, ninguno. Analyze, tests, commit y push.
```

---

## Iteración 13 — Release de Android (Build 12)

**Antes (Federico):** `android\key.properties` con `storeFile=C:\\dev\\keys\\anunnaki-upload.jks`, `keyAlias=upload` y la contraseña (si no existe todavía). **Cowork:** política de privacidad nueva (sin cuenta, sin IA en vivo, sin servidor: solo AdMob y la compra de la tienda) y los cambios de "Seguridad de los datos" en Play Console, para publicarlos con tu OK.

```
Iteración 13 — Release de Android (ver Release en CLAUDE.md). Entorno: reglas de CLAUDE.md.
Firma de release leyendo android/key.properties (ignorado por git) con plantilla key.properties.example; si falta, que el build falle con un mensaje claro. Ícono adaptativo y splash con flutter_launcher_icons y flutter_native_splash desde assets/icon/icon.png, fondo #0A0E1A (revisá después el manifest: portrait y label). R8 con las reglas que pida AdMob. Versión 1.1.0+12. Corré la validación de historias en modo estricto para las aventuras con historia: si a alguna le falta el inglés, avisame antes de seguir. Generá el appbundle y un APK de release para probar en el emulador. Escribí docs/release.md con la receta paso a paso. Commit y push.
```

**Después (Federico):** Play Console → Prueba cerrada (Alpha) → Crear versión → subir `build\app\outputs\bundle\release\app-release.aab` → notas "Nueva versión: historias con varios finales, sin cuenta, compra única" → revisar y lanzar. Con este build conviene invitar a los 11 testers que faltan: los 14 días pueden correr mientras se terminan las historias. **Producción**, solo con las 10 historias escritas y traducidas.

---

## Iteraciones 14 y 15 — iOS

- **14, iOS base:** Info.plist (`GADApplicationIdentifier` con el ID de iOS, `SKAdNetworkItems`, `NSUserTrackingUsageDescription`, `UIRequiresFullScreen`, solo vertical), IDs de AdMob por plataforma y `codemagic.yaml` con `ios-check` copiando la estructura del de Ovun (de lectura). Se prueba en Codemagic (unos 15–20 de los 500 minutos del mes). No necesita la membresía de Apple.
- **15, TestFlight:** con la membresía de Apple activa: Bundle ID con In-App Purchase, app en App Store Connect, producto `anunnaki_completo` (no consumible), mensaje IDFA en AdMob, integración de Codemagic con App Store Connect y workflow de release que sube a TestFlight. **Ya no hace falta** Sign in with Apple ni la revocación del token: no hay cuenta.

---

## Limpieza de servicios viejos (con OK de Federico, después del Build 12 en la prueba cerrada)

- Supabase: borrar las funciones `narrative` y `delete-account`, y después pausar o borrar el proyecto. Antes, si se quiere, exportar la tabla `adventures` (ya copiada en `catalog.json`).
- Anthropic: revocar la clave de API que usaba `narrative`.
- Play Console: desactivar las suscripciones `anunnaki_premium_monthly` y `anunnaki_premium_yearly` (nadie las compró); actualizar la ficha (sin "IA en vivo") y "Seguridad de los datos" (sin cuenta); la URL de eliminación de cuenta deja de ser obligatoria.
- RevenueCat y los clientes OAuth de Google: sin uso; se pueden dejar o borrar.
- Páginas legales: reemplazar `delete_account.html` por una nota de que no hay cuenta, o quitarla de la ficha.
