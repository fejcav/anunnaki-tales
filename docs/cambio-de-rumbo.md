# Cambio de rumbo: Anunnaki Tales sin servidor, sin cuenta y con compra única

2 de octubre de 2026 · Decisión de Federico. Este documento manda sobre lo que diga `CLAUDE.md` hasta que se actualice (iteración 9) y reemplaza a la versión 1 del plan.

## Qué se decidió y por qué

Anunnaki se armó al revés que Ovun: servidor obligatorio (Supabase), cuenta obligatoria, IA paga en cada elección (función `narrative`) y suscripción (RevenueCat). De ahí salían casi todos los problemas: costo por uso que crece con cada jugada, riesgo de abuso de la IA, seguridad de la función, correo de recuperación, SMTP, eliminación de cuenta, Supabase que se pausa, claves.

**Desde ahora, Anunnaki se hace como Ovun:**

| | Antes | Ahora |
|---|---|---|
| Historias | IA en vivo (Claude Haiku) en cada elección | **Árboles de escenas escritos de antemano** en `assets/data/stories/`, revisados por Federico |
| Servidor | Supabase + funciones `narrative` y `delete-account` | **Ninguno** |
| Cuenta | Obligatoria (correo y contraseña) | **No hay cuenta** |
| Progreso | En Supabase | En el teléfono (`shared_preferences`) |
| Cobro | Suscripción mensual/anual con RevenueCat | **Compra única** con `in_app_purchase` (como la compra "Sin anuncios" de Ovun) |
| Límite diario | 3 elecciones gratis por día | **Sin límite** (existía para frenar el costo de la IA) |
| Héroe | Se elegía entre varios | **Protagonista fijo por aventura**; la pantalla pasa a ser una presentación ("Tu héroe") |
| Costo por jugador | Crece con cada elección | Cero |

Lo que se reaprovecha: el tema, las fuentes, los textos de interfaz, Inicio, Catálogo, Gameplay (`ChoiceButton`, `HistoricalFactCard`), el guardado local, los IDs de AdMob, la ficha de Play Console, el package y la clave de subida.

Lo que deja de usarse (sin borrarlo todavía del lado de los servicios): Supabase (base, Auth, funciones), RevenueCat, las suscripciones de Play Console y los clientes OAuth de Google creados el 02/10. La limpieza se hace después de que el Build 12 reemplace al 11 en la prueba cerrada (ver el plan).

## Decisiones por defecto (Federico puede cambiarlas)

- **Gratis:** las 3 aventuras con `is_free = true` en el catálogo de hoy: `gilgamesh_enkidu` (El Hombre Salvaje de Uruk), `descent_inanna` (Descenso a la Oscuridad) y `lugalbanda_anzu` (El Rey Pastor), con anuncios.
- **Compra única "Anunnaki Tales completo"** (producto `anunnaki_completo`, no consumible): desbloquea las 10 aventuras y quita los anuncios, para siempre. Precio sugerido: USD 3,99 (lo fija Federico en Play Console; la app muestra el que devuelve la tienda).
- **Aventuras sin historia escrita todavía:** aparecen en el catálogo con la etiqueta "Próximamente" y no se pueden abrir.
- **Idioma:** el de la interfaz (el del teléfono). Si a una historia le falta el inglés, se muestra el español.
- **Sin nube por ahora.** Una copia opcional en la nube, como la de Ovun, queda para más adelante si hace falta.

## Reglas nuevas para `CLAUDE.md` (iteración 9 las vuelca)

Reemplazar en `CLAUDE.md` las secciones indicadas por lo siguiente. Lo que no se nombra acá (Entorno, Aspecto, Cómo trabajar, reglas de emulador y disco, convivencia con Ovun, Release salvo lo indicado) queda igual.

### Introducción

Anunnaki Tales es un juego narrativo para Android e iOS ambientado en la mitología mesopotámica: el jugador elige un mito y vive la historia de su protagonista escena por escena; en cada escena hay hasta tres opciones con distinto riesgo y, muchas veces, un dato histórico real. Las historias están escritas de antemano (en `assets/data/stories/`, una por aventura) y cada una tiene varios finales. No hay servidor ni cuenta: todo se guarda en el teléfono. Tres aventuras son gratis con anuncios; una compra única desbloquea todas y quita los anuncios. (Hasta el 02/10/2026 la app dependía de Supabase, de una IA en vivo y de RevenueCat; ver `docs/cambio-de-rumbo.md`.)

### Stack

- Flutter estable, Dart. `provider` + `ChangeNotifier`. Sin Riverpod, Bloc ni generación de código.
- Contenido: archivos JSON en `assets/data/` (catálogo e historias), leídos con `rootBundle`.
- Persistencia: `shared_preferences` con un único JSON serializado a mano.
- Compra: `in_app_purchase` + `in_app_purchase_android` (desde la iteración 11), igual que Ovun.
- Anuncios: `google_mobile_ads` (AdMob + UMP), desde la iteración 12.
- `url_launcher`, `package_info_plus`, `flutter_localizations` + `intl` (ARB), `flutter_animate`, fuentes TTF estáticas (Cinzel, Lora, Inter).
- **Fuera del proyecto:** `supabase_flutter`, `purchases_flutter`, `google_sign_in`, `sign_in_with_apple`, `crypto`.
- Herramientas de desarrollo: `flutter_launcher_icons`, `flutter_native_splash`.

### Estructura

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
  state/app_state.dart   ChangeNotifier: catálogo, partida actual, finales descubiertos, compra
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

### Contenido (reemplaza la sección "Backend")

- `assets/data/catalog.json`: lista de aventuras con `id`, `sortOrder`, `difficulty` (`easy|medium|hard`), `isFree`, `title`, `subtitle`, `description` (cada texto `{es, en}`). Se generó una sola vez desde la tabla `adventures` de Supabase (iteración 9) y desde ahí se edita a mano.
- `assets/data/stories/<id>.json`: formato y reglas en `docs/formato-historias.md`. El test `story_validation_test.dart` aplica esas reglas a todos los archivos; en modo estricto (para el release) exige el inglés completo.
- Las historias las escribe Cowork en el proyecto de claude.ai y Federico las aprueba. Claude Code no inventa ni reescribe texto narrativo: si encuentra un error, lo señala.
- Una aventura sin archivo de historia se muestra como "Próximamente".

### Reglas de juego

- **Inicio**: "ANUNNAKI TALES", "Mitos Interactivos", "Comenzar aventura" (va al Catálogo) y "Continuar partida" (solo si hay una partida guardada cuya historia y escena existen; muestra el título de la aventura). Arriba a la derecha, el ícono de Ajustes.
- **Catálogo** ("Elige tu aventura"): una tarjeta por aventura en `sortOrder`, con título, subtítulo, dificultad con color y "~N escenas" (camino más corto hasta el final del mito, calculado de la historia). Si ya descubrió finales: "Finales: N de M". Estados: abierta, **con candado** (no gratis y sin compra: tocarla abre el Paywall) o **"Próximamente"** (sin historia; no se abre).
- **Tu héroe**: nombre y descripción del protagonista (`hero` de la historia), descripción de la aventura y "Empezar". Empezar una aventura reemplaza la partida guardada.
- **Gameplay**: arriba "Capítulo N · Título" y "Turno N" (cantidad de escenas vistas en esta partida); el texto en Lora, separado en párrafos por las líneas en blanco; la tarjeta "Dato histórico" si la escena tiene `fact`; las opciones con `ChoiceButton` (punto de color, texto, descripción y "Riesgo bajo / medio / alto"; una opción sin `risk` va sin punto ni etiqueta). Elegir es instantáneo. La partida se guarda en cada escena. La flecha atrás vuelve a Inicio.
- **Final**: tipo ("Final del mito", "Final alternativo", "Final trágico"), título en Cinzel, texto, dato histórico, "Finales descubiertos: N de M" y los botones "Volver a jugar", "Otra aventura" y, solo en finales trágicos, "Volver a la última decisión". Al llegar a un final se guarda como descubierto y se borra la partida guardada.
- **Ajustes** (reemplaza a Perfil): "Desbloquear todo" o "Todo desbloqueado" (iteración 11), "Restaurar compra" (iteración 11), "Privacidad de anuncios" (solo si UMP lo exige, iteración 12), "Política de privacidad", "Borrar progreso" (con confirmación dentro de la pantalla: borra la partida guardada y los finales descubiertos, no la compra) y la versión.
- No hay límite diario, cuenta, ingreso, cerrar sesión ni eliminar cuenta.

### Compra única (reemplaza la sección "Premium")

- Producto no consumible **`anunnaki_completo`** en Google Play (y en App Store desde la iteración 15). Precio: el que devuelve la tienda, nunca escrito a mano.
- Desbloquea todas las aventuras y quita los anuncios. Paywall ("Desbloquea todos los mitos"): beneficios **solo los que existen** (las aventuras ya escritas, sin anuncios, pago único sin suscripción), precio de la tienda, "Comprar", "Restaurar compra" y "Ahora no".
- Se implementa como la compra "Sin anuncios" de Ovun (`C:\dev\ovun\lib\services\purchases.dart` y `lib\logic\purchase_rules.dart`, **solo como referencia de lectura; no se toca nada de Ovun**): escuchar `purchaseStream`, completar las compras pendientes, reconocerlas, restaurar al pedirlo, y guardar el estado en `localData` para arrancar sin esperar a la tienda.

### Anuncios (cambios)

- Lo que decía "Premium" ahora es "con la compra hecha".
- Banner al pie de Catálogo y de Tu héroe. Intersticial al tocar "Empezar" (precargado al entrar a Tu héroe; si no está listo, se sigue sin anuncio). Nunca en Gameplay, Final, Paywall ni Ajustes.

### Datos en shared_preferences

Una sola clave, `localData`: JSON con `schemaVersion` 2, `language` (`null` = el del teléfono), `savedGame` (o `null`: `adventureId`, `sceneId`, `path` = lista de ids de las escenas vistas), `endingsFound` (`{ adventureId: [ids de finales] }`) y `purchased` (booleano, desde la iteración 11). Al leer un `schemaVersion` 1 se descarta la partida guardada vieja y el contador de elecciones. Si no se puede leer, se empieza de cero.

### Release (cambios)

- Sin reglas de R8 de RevenueCat. Permisos: `INTERNET` y `com.google.android.gms.permission.AD_ID` (el de facturación lo agrega la librería de compras).
- iOS sin Sign in with Apple ni `GIDClientID` (no hay ingreso).
- Antes de cada release: `flutter test` con la validación de historias en modo estricto para las aventuras publicadas.

### Fases

0–8. Hechas con la arquitectura vieja (8, Premium con RevenueCat, queda reemplazada).
9. Historias locales (el juego completo sin servidor).
10. Sin cuenta ni servidor (se quitan Supabase y RevenueCat).
11. Compra única.
12. Anuncios con consentimiento.
13. Release de Android (Build 12).
14–15. iOS con Codemagic y TestFlight.
En paralelo: contenido (una historia por vez) y limpieza de servicios viejos.

### Abiertos

- Precio de la compra única y qué aventuras son gratis (por defecto, las 3 de hoy).
- Si más adelante conviene una copia opcional en la nube, como en Ovun.
