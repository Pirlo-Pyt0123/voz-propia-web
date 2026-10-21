# Voz Propia — App móvil

App Android nativa (Flutter) de **clonación de voz few-shot** pensada para personas con
pérdida progresiva del habla (ELA, laringectomía): graban su voz mientras todavía pueden
hablar con claridad y, más adelante, pueden escribir cualquier frase y escucharla dicha
con su propia voz.

Prototipo de Taller de Especialidad — Ingeniería en Ciencias de la Computación.

Este repositorio contiene **solo el frontend** (la app Android). El backend vive en un
repositorio aparte: [`voz-propia-backend`](../voz-propia-backend) (FastAPI + PostgreSQL +
Celery/Redis + Chatterbox TTS).

---

## Índice

- [Stack](#stack)
- [Instalación](#instalación)
  - [1. Backend](#1-backend)
  - [2. App Android](#2-app-android)
  - [3. Conectar el teléfono al backend](#3-conectar-el-teléfono-al-backend)
- [Manual de usuario](#manual-de-usuario)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Desarrollo](#desarrollo)

---

## Stack

- **Flutter** (Dart) — app Android nativa, sin versión web.
- `provider` — manejo de estado (`AuthController`).
- `record` — grabación de audio del micrófono.
- `file_picker` + `path_provider` — subir un audio existente / guardar audio generado en el dispositivo.
- `shared_preferences` — preferencias locales (ej. guardado automático de audio).
- `google_fonts` (Manrope) — tipografía.
- Diseño propio **Neo-Brutalista**: bordes gruesos, sombras duras sin blur, colores planos (`lib/theme/brutal_theme.dart`).

---

## Instalación

### 1. Backend

El backend corre aparte y expone la API en `http://localhost:8000`. Instrucciones
completas en el README de [`voz-propia-backend`](../voz-propia-backend/README.md); resumen
rápido con Docker (recomendado):

```bash
cd ../voz-propia-backend
cp .env.example .env
docker compose up --build
```

Esto levanta Postgres, Redis, la API (con migraciones automáticas) y el worker de Celery
(entrenamiento/síntesis de voz corren en background — sin el worker, esas tareas se quedan
encoladas para siempre). Docs interactivas en `http://localhost:8000/docs`.

### 2. App Android

**Opción A — instalar el APK ya compilado (rápido, para probar/evaluar):**

1. Copiá el `.apk` al teléfono (o descargalo directo ahí).
2. Abrilo y permití "instalar apps de origen desconocido" si Android lo pide.
3. Listo — ver el paso 3 para conectarla al backend.

**Opción B — compilar desde el código fuente:**

Requiere Flutter (este proyecto usa [`fvm`](https://fvm.app/) para fijar la versión —
`.fvmrc` ya está en el repo).

```bash
fvm flutter pub get
fvm flutter build apk --release
# el APK queda en build/app/outputs/flutter-apk/app-release.apk
```

O para correrla directo en un dispositivo conectado por USB (con depuración USB activada):

```bash
fvm flutter run --release
```

### 3. Conectar el teléfono al backend

La app apunta por defecto a `http://localhost:8000` (ver `lib/config/api_config.dart`).
Para que un teléfono físico conectado por USB llegue al backend que corre en tu
computadora:

```bash
adb reverse tcp:8000 tcp:8000
```

Repetilo cada vez que reconectes el cable. Si la app y el backend NO van a estar en la
misma máquina (ej. demo sin cable, backend en la red local), compilá apuntando a la IP de
esa máquina:

```bash
fvm flutter build apk --release --dart-define=API_BASE_URL=http://<ip-de-tu-pc>:8000
```

---

## Manual de usuario

### Registro e inicio de sesión

Pantalla inicial: crear cuenta (nombre, email, contraseña) o iniciar sesión. El rol por
defecto es `user`; el rol `administrator` habilita una sección extra (ver más abajo).

### Dashboard

Pantalla principal con accesos a **Grabaciones**, **Síntesis de voz**, **Ajustes** y
(solo administradores) **Administración**.

### Grabaciones — crear tu perfil de voz

1. Entrá a "Grabaciones" y presioná grabar.
2. Leé en voz alta la frase que aparece en pantalla — una **guía de lectura tipo karaoke**
   resalta cada palabra a medida que se supone que la vas leyendo, para ayudarte con el
   ritmo.
3. También podés **subir un audio existente** en vez de grabar en el momento.
4. Una barra de progreso muestra cuánto audio válido acumulaste hacia el mínimo necesario
   para entrenar el modelo (no importa si es una grabación larga o varias cortas, cuenta
   la duración total).
5. Con suficiente audio acumulado, se habilita "Entrenar" — esto manda el audio al backend
   para que clone tu voz (tarda uno o varios minutos; corre en background).

### Síntesis de voz — hablar con tu voz clonada

1. Con el perfil de voz ya entrenado (`listo`), entrá a "Síntesis".
2. Escribí cualquier frase y presioná generar.
3. Cuando termina, podés **reproducirla**, **calificarla con 1 a 5 estrellas** (qué tan
   parecida sonó a tu voz real), **guardarla en el dispositivo** y **borrarla**.
4. El historial de frases generadas queda disponible para volver a escucharlas o
   borrarlas (una por una o todas).

### Ajustes

- Editar nombre/email del perfil.
- Cambiar contraseña.
- Activar/desactivar el guardado automático del audio generado en el dispositivo.
- Borrar el perfil de voz o la cuenta por completo (acción irreversible).

### Administración (solo rol `administrator`)

- Estadísticas agregadas: promedio de calificación (MOS), cantidad de usuarios, perfiles
  de voz, grabaciones, frases sintetizadas, y perfiles agrupados por estado.
- Tabla de usuarios con buscador y opción de borrar una cuenta (y todo lo asociado).

---

## Estructura del proyecto

```
lib/
  config/        # API_BASE_URL
  models/        # modelos de datos (usuario, grabación, frase sintetizada, admin)
  screens/       # una pantalla por archivo (dashboard, recordings, synthesis, settings, admin, login)
  services/      # ApiClient, AuthController, preferencias, guardado/lectura de audio
  theme/         # sistema de diseño Neo-Brutalista (BrutalColors, BrutalDecoration)
  widgets/       # componentes reutilizables (BrutalButton, BrutalCard, BrutalTextField, ...)
android/         # proyecto Android nativo
```

## Desarrollo

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

Con el backend corriendo y `adb reverse tcp:8000 tcp:8000` activo:

```bash
fvm flutter run
```
