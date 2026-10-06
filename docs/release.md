# Release — receta paso a paso (Android en la PC, iOS en Codemagic)

Cómo compilar el `.aab` en la PC y subirlo a mano a Play Console (prueba
cerrada). Primera vez: Build 12 (versión 1.1.0+12), 05/10/2026.

Todos los comandos se escriben en una terminal abierta en `C:\dev\anunnaki-tales`.

## Una sola vez: la clave de subida

1. El keystore de subida está en `C:\dev\keys\anunnaki-upload.jks` (alias
   `upload`, RSA 2048), con respaldo fuera de la PC. Es el que Play Console
   tiene registrado como clave de subida: **no se cambia ni se regenera**.
2. Copiar `android\key.properties.example` como `android\key.properties` y
   completar las dos contraseñas. Ese archivo está ignorado por git: nunca se
   commitea ni se pega en ningún lado.
3. Si falta `android\key.properties`, el build de release se corta con el
   mensaje "Falta android/key.properties…" (en vez de firmar con la clave de
   debug, que Play rechazaría).

## Cada release

1. **Que no haya otra cosa compilando.** Cerrar cualquier build o emulador de
   Ovun. Mirar que en C: haya al menos 15 GB libres.
2. **Subir la versión** en `pubspec.yaml`, línea `version:`. Lo que va antes
   del `+` es la versión visible (por ejemplo `1.1.1`); lo de después es el
   versionCode y **tiene que ser mayor que el último subido** a Play (el Build
   12 usó `1.1.0+12`; el próximo sería `+13`).
3. **Revisar el código y las historias:**
   ```
   flutter analyze
   flutter test
   flutter test test/story_validation_test.dart --dart-define=STRICT_STORIES=true
   ```
   Los tres tienen que terminar sin errores. El último exige el inglés
   completo en todas las historias: si falla, dice qué texto falta y en qué
   escena; se completa la traducción antes de seguir.
4. **Compilar:**
   ```
   flutter build appbundle --release
   ```
   Tarda unos 3 minutos la primera vez. El archivo queda en
   `C:\dev\anunnaki-tales\build\app\outputs\bundle\release\app-release.aab`.
5. **(Opcional) Verificar la firma:**
   ```
   keytool -printcert -jarfile build\app\outputs\bundle\release\app-release.aab
   ```
   Tiene que decir "Propietario: CN=Federico Cavallo, … O=Anunnaki Tales"; si
   dice "Android Debug", algo está mal con `key.properties`.
6. **(Opcional) Probar el mismo build en el emulador:**
   ```
   flutter build apk --release
   adb -s emulator-5560 install -r build\app\outputs\flutter-apk\app-release.apk
   ```
   En release los anuncios son los reales: **no tocarlos**. El emulador cuenta
   como dispositivo de prueba (los anuncios salen con la marca "Test Ad"). En
   un teléfono propio, registrarlo antes como dispositivo de prueba en AdMob.
   Ojo: si la cuenta de Google del emulador ya compró `anunnaki_completo`, la
   app lo restaura al abrir y no muestra anuncios (es lo correcto).
7. **Subir a Play Console:**
   1. Entrar a Play Console → Anunnaki Tales → Pruebas → **Prueba cerrada
      (Alpha)** → **Crear versión**.
   2. En "App bundles", **Subir** y elegir el `app-release.aab` del paso 4.
   3. Nombre de la versión: lo completa solo (por ejemplo `12 (1.1.0)`).
   4. Notas de la versión (en español y en inglés), por ejemplo: "Nueva
      versión: historias con varios finales, sin cuenta, compra única".
   5. **Siguiente** → revisar los avisos (los amarillos se pueden leer y
      seguir; los rojos hay que resolverlos) → **Guardar** → **Enviar a
      revisión** / **Lanzar**.
8. **Commit** del cambio de versión: `git commit -am "Versión 1.1.0+12"` y
   `git push`.

## Ícono y pantalla de arranque (solo si cambia el dibujo)

Se generan desde `assets/icon/icon.png` (fondo `#0A0E1A`). La configuración
está en `pubspec.yaml`.

```
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

- La pantalla de arranque usa `assets/icon/splash.png`: el mismo ícono
  achicado al centro de un lienzo transparente de 1152×1152 (Android 12+
  recorta el centro en círculo). Si cambia `icon.png`, hay que rehacerlo igual.
- **Después de regenerar el splash**, revisar `android\app\src\main\AndroidManifest.xml`:
  el comando le borra `android:screenOrientation="portrait"` y reformatea el
  archivo (también reformatea `ios\Runner\Info.plist`). Lo más simple es
  devolverlos como estaban: `git checkout -- android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist`.
  Confirmar que sigan `portrait` y `android:label="Anunnaki Tales"`.

## Qué hay configurado (para no tocarlo sin querer)

- `android\app\build.gradle.kts`: firma de release con `key.properties`, R8
  activo con `proguard-rules.pro`, y el corte con mensaje claro si falta la
  clave.
- `android\app\proguard-rules.pro`: una regla para que R8 no borre el
  constructor de Room que usa el SDK de anuncios (sin ella la app se cerraba
  al abrir; mismo caso que Ovun).
- `AndroidManifest.xml`: permisos `INTERNET` y `AD_ID`, el ID de la app de
  AdMob (`ca-app-pub-8769741188201469~9074937716`), solo vertical.

## iOS: compilar en Codemagic (`ios-check`)

No hay Mac: iOS se compila en Codemagic, en la misma cuenta que Ovun (los 500
minutos gratis de macOS por mes se comparten entre las dos apps). Por ahora
solo existe `ios-check`, que **compila sin firmar** y no sube nada; sirve para
saber que iOS compila sin tener todavía la membresía de Apple. Firmar y subir
a TestFlight es la iteración 15.

### Qué hace `ios-check` (`codemagic.yaml`, en la raíz)

En una Mac mini M2, con Flutter estable y Xcode al día: `flutter pub get`,
`flutter analyze`, `flutter test --dart-define=STRICT_STORIES=true`,
`pod install` en `ios/` y `flutter build ios --release --no-codesign`. Corta a
los 30 minutos. Al terminar (bien o mal) manda un mail a fejcavallo@gmail.com.
Si falla, el log de Xcode queda en los artefactos del build.

### Una sola vez: agregar la app en Codemagic

1. Entrar a codemagic.io con la cuenta de Ovun → **Add application**.
2. Elegir **GitHub** y el repo `fejcav/anunnaki-tales` (si no aparece, darle
   acceso a Codemagic a ese repo en la configuración de la GitHub App).
3. Tipo de proyecto: **Flutter App (via codemagic.yaml)**. Codemagic lee
   `codemagic.yaml` de la rama `main`; no hace falta configurar nada más.

### Cada vez que se quiera comprobar iOS

1. Hacer push a `main`.
2. En Codemagic → Anunnaki Tales → **Start new build** → rama `main`,
   workflow **iOS → solo compilar, sin firma** → **Start new build**.
3. Tarda unos 10–15 minutos. No corre solo con cada push (a propósito): cada
   corrida descuenta minutos del cupo mensual compartido con Ovun.
4. Llega un mail con el resultado. Si falla, en Codemagic se ve en qué paso;
   el log completo de Xcode queda en los artefactos del build.

### Qué hay configurado en iOS

- `ios/Runner/Info.plist`: ID de app de AdMob para iOS
  (`ca-app-pub-8769741188201469~2296085996`), la lista de `SKAdNetworkItems`
  que recomienda Google (copiada de developers.google.com/admob/ios/3p-skadnetworks;
  conviene repasarla de vez en cuando), el texto del permiso de seguimiento
  (ATT) en inglés, `UIRequiresFullScreen`, solo vertical (iPhone y iPad),
  nombre "Anunnaki Tales" e idiomas en/es.
- `ios/Runner/es.lproj/InfoPlist.strings`: el texto del permiso de
  seguimiento en español. Está registrado en el proyecto de Xcode (si no, no
  se copia a la app).
- `ios/Podfile`: iOS 15 como mínimo (igual que el proyecto de Xcode).
- Bundle ID `com.mycompany.anunnakitales` en Debug, Release y Profile.
- Ícono y splash de iOS: los genera `flutter_launcher_icons` /
  `flutter_native_splash` (ver arriba), con `remove_alpha_ios: true` porque
  la App Store rechaza íconos con transparencia.
- Compra en iOS: la app **no** consulta la tienda al arrancar (restaurar
  puede pedir la contraseña de Apple). La compra se recupera solo con el
  botón "Restaurar compra".
