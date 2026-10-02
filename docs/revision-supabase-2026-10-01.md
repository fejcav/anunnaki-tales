# Revisión de seguridad de Supabase — 01/10/2026

Revisión de solo lectura del proyecto `wtkohxujhvaxoablfevz`. No se cambió código ni la base, y no se hizo ningún GET de filas ni ningún POST, PATCH o DELETE. La anon key no se copia en este informe (su JWT dice `role: anon`, como corresponde).

Security Advisor del panel: https://supabase.com/dashboard/project/wtkohxujhvaxoablfevz/advisors/security

## 1. Inventario desde el código

Búsqueda de `.from(`, `.rpc(`, `.storage` y `functions.invoke` en `lib/` (y, como referencia, en la rama `flutterflow`).

| Recurso | Tipo | Dónde | Operación | Datos |
|---|---|---|---|---|
| `adventures` | tabla | `lib/services/story_api.dart:23` | select (`is_active = true`, orden `sort_order`) | públicos (catálogo) |
| `adventure_characters` | tabla | `lib/services/story_api.dart:36` | select con `characters(*)` embebido | públicos (catálogo) |
| `characters` | tabla | embebida en la consulta anterior | select | públicos (catálogo) |
| `narrative` | Edge Function | `lib/services/story_api.dart` | invoke (`start`, `continue`, `load`) | del usuario (`game_sessions`) |
| `delete-account` | Edge Function | `lib/services/auth_service.dart` | invoke sin body | del usuario (Auth) |
| Supabase Auth | Auth | `lib/services/auth_service.dart` | signUp, signIn, reset con OTP, updateUser, signOut | del usuario |

- **RPC:** ninguna. **Storage:** ninguno (ni en la app nueva ni en la de FlutterFlow).
- La app **no escribe en ninguna tabla**: todo lo del usuario lo escriben las Edge Functions con la service_role.
- Tablas del backend que la app no usa directamente, pero que existen (según los modelos de la rama `flutterflow`): `profiles`, `game_sessions`, `turns`, `purchases`, `user_achievements` (del usuario) y `achievements`, `daily_facts` (contenido). También se probaron.

## 2. SQL en el repo

**No hay SQL en el repo**: ni migraciones, ni archivos `.sql`, ni `supabase/config.toml` (tampoco en la rama `flutterflow`). Lo único de Supabase son las copias de las dos Edge Functions en `supabase/functions/`. **Las políticas RLS viven solo en el panel de Supabase**: desde acá no se puede saber qué políticas tiene cada tabla ni si filtran por `auth.uid()`.

Lo que sí se ve en las funciones:

- `narrative` usa la **service_role** para leer y escribir `game_sessions`: saltea RLS por completo, así que las políticas de esa tabla no la protegen.
- `delete-account` identifica al usuario por su JWT (`auth.getUser()` con el header `Authorization`) y recién después usa la service_role para borrarlo. Bien hecho.

## 3. Prueba desde afuera (HEAD sin sesión, solo anon key)

`HEAD /rest/v1/<tabla>?select=*` con `apikey`, `Authorization: Bearer <anon>` y `Prefer: count=exact`.

| Tabla | Datos | RLS | Políticas | HEAD | Total (Content-Range) | Lectura |
|---|---|---|---|---|---|---|
| `adventures` | catálogo | no se sabe | no se sabe (lectura pública esperada) | 200 | 10 | OK, es público |
| `characters` | catálogo | no se sabe | no se sabe (lectura pública esperada) | 200 | 15 | OK, es público |
| `adventure_characters` | catálogo | no se sabe | no se sabe (lectura pública esperada) | 200 | 28 | OK, es público |
| `achievements` | contenido | no se sabe | no se sabe | 200 | 18 | OK, es público |
| `daily_facts` | contenido | no se sabe | no se sabe | 200 | 10 | OK, es público |
| `profiles` | usuario | probablemente sí | no se sabe | 200 | 0 | OK sin sesión |
| `game_sessions` | usuario | probablemente sí | no se sabe | 200 | 0 | OK sin sesión |
| `turns` | usuario | probablemente sí | no se sabe | 200 | 0 | OK sin sesión |
| `purchases` | usuario | probablemente sí | no se sabe | 200 | 0 | OK sin sesión |
| `user_achievements` | usuario | probablemente sí | no se sabe | 200 | 0 | OK sin sesión |

Además, la raíz `/rest/v1/` (el esquema OpenAPI con la lista de tablas) responde **401** a la anon key: no se puede enumerar el esquema desde afuera.

Ninguna tabla con datos de usuarios devuelve filas sin sesión: **no hay hallazgo ALTA en esta prueba.** Dos límites de la prueba:

- Un total de 0 se ve igual si RLS oculta las filas que si la tabla está vacía. Con la app de FlutterFlow en prueba cerrada, `profiles` casi seguro tiene filas, así que lo más probable es que RLS esté activado; igual hay que confirmarlo en el panel.
- La prueba es **sin sesión**. No dice si un usuario con sesión puede leer las filas de **otro** usuario (eso depende de que la política use `auth.uid() = user_id` y no solo `to authenticated`), ni si alguien puede **escribir** en las tablas del catálogo.

## 4. Eliminar cuenta

- La app llama a la Edge Function `delete-account` (`supabase.functions.invoke('delete-account')`, sin body). No borra nada con la anon key.
- La función toma el usuario **del JWT de la sesión** (nunca de un id del cliente) y lo borra de Auth con `auth.admin.deleteUser` usando la service_role, que lee de la variable de entorno `SUPABASE_SERVICE_ROLE_KEY` del servidor.
- Lo demás cae en cascada por las foreign keys: `profiles → game_sessions → turns`, `purchases`, `user_achievements` (según el comentario de la función; las foreign keys no se pueden ver desde el repo).
- Después la app cierra la sesión de Supabase y de RevenueCat y borra los datos locales.
- No cancela suscripciones de las tiendas (se avisa en el diálogo) y todavía no revoca el token de Apple (iteración 13).

**La service_role no está en el repo ni en el historial.** `git log --all -p -S service_role` no encontró nada. La búsqueda sin distinguir mayúsculas solo encuentra el nombre de la variable `SUPABASE_SERVICE_ROLE_KEY` en las dos funciones, nunca su valor. El único JWT del historial (en todas las ramas, incluida `flutterflow`) es la anon key (`role: anon`). No hay claves nuevas `sb_secret_…`.

## 5. Hallazgos

### ALTA

**A1. `narrative` no exige usuario: cualquiera con la anon key puede gastar IA sin límite.**
La función no revisa quién la llama: acepta el JWT de la anon key (que es público y está en la app) y no lee el usuario. Con un script, alguien puede llamar a `start` sin parar y cada llamada es una petición a Claude Haiku pagada con la clave de Anthropic del proyecto. El límite de 3 elecciones por día vive solo en el teléfono, así que tampoco frena esto. (No se probó con un POST, como se pidió; se deduce leyendo el código desplegado.)
*Arreglo propuesto* (es la iteración 15 del plan): que la función tome el usuario del JWT como hace `delete-account` (`auth.getUser()`), rechace con 401 las llamadas sin sesión de usuario real e ignore el `user_id` del body. Como red de seguridad, poner un tope de gasto mensual en la consola de Anthropic. Opcional: un límite de llamadas por usuario y por día en el servidor.

### MEDIA

**M1. `narrative` deja leer y modificar partidas ajenas si se conoce su `session_id`.**
`load` y `continue` buscan la partida solo por `id`, con la service_role, sin comparar `user_id` con quien llama. Quien tenga un `session_id` ajeno puede leer la escena de otra persona y avanzar su partida. `start` además acepta cualquier `user_id`, así que se pueden crear partidas a nombre de otro usuario. Lo mitiga que los ids son UUID (no se adivinan) y que el contenido es una historia, no datos personales; por eso queda en MEDIA y no en ALTA.
*Arreglo propuesto:* el mismo de A1 y, en `load` y `continue`, filtrar con `.eq('user_id', <usuario del JWT>)` (responder 404 si no es suya).

**M2. Las políticas RLS no se pueden verificar desde el repo.**
No hay SQL versionado. La prueba HEAD solo muestra que sin sesión no se leen filas de usuarios. No muestra si un usuario con sesión puede leer las filas de otro, ni si el catálogo (`adventures`, `characters`, `adventure_characters`, `achievements`, `daily_facts`) acepta INSERT/UPDATE/DELETE de la anon key o de un usuario cualquiera.
*Arreglo propuesto:* abrir el Security Advisor (link arriba) y, en el SQL Editor, correr solo lectura: `select tablename, rowsecurity from pg_tables where schemaname = 'public';` y `select * from pg_policies where schemaname = 'public';`. Confirmar: RLS activado en todas; en las tablas de usuario, políticas con `auth.uid() = user_id` (o `= id` en `profiles`); en el catálogo, solo SELECT. Después guardar ese SQL en el repo (por ejemplo `supabase/policies.sql`) como referencia, igual que las funciones.

### BAJA

**B1. `narrative` devuelve mensajes técnicos en los errores.** El 404 de `continue` incluye `details: sessionError.message` y el 500 devuelve `error.message`. Puede filtrar detalles internos (nombres de columnas, errores de Postgres). La app no los muestra, pero cualquiera que llame la función los ve.
*Arreglo propuesto:* responder mensajes fijos y dejar el detalle solo en `console.error`.

**B2. "Verify JWT" de las funciones no se ve desde el repo.** `delete-account` igual se protege sola (rechaza si `getUser()` falla). En `narrative`, aunque esté activado, la anon key pasa la verificación, así que no alcanza (ver A1).
*Arreglo propuesto:* confirmar en el panel (Edge Functions → cada función → Settings) que esté activado en las dos.

**B3. `purchases` y `user_achievements` sin escritor conocido.** La app no las usa. Si alguna política permite INSERT o UPDATE a usuarios con sesión, alguien podría marcarse compras o logros que no tiene. Hoy el Premium se lee de RevenueCat, no de esa tabla, así que el impacto es bajo.
*Arreglo propuesto:* incluirlas en la revisión de M2 y dejarlas sin políticas de escritura para `anon` y `authenticated`.
