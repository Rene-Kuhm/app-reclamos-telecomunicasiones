# Reclamos Telco - Flutter Mobile App

Sistema móvil de gestión de reclamos para telecomunicaciones desarrollado con Flutter siguiendo Clean Architecture.

## Características

- Autenticación JWT con refresh tokens automático
- Gestión completa de reclamos (CRUD)
- Sistema de notificaciones
- Perfil de usuario con cambio de contraseña
- Soporte para tema claro/oscuro
- Caché offline con Hive
- Almacenamiento seguro con flutter_secure_storage
- Validación de formularios
- Manejo de errores robusto
- Material Design 3

## Arquitectura

El proyecto sigue Clean Architecture con la siguiente estructura:

```
lib/
├── core/                      # Funcionalidad compartida
│   ├── config/               # Configuración de la app
│   │   ├── app_config.dart   # Constantes y configuración
│   │   ├── router.dart       # Navegación con go_router
│   │   └── theme.dart        # Temas Material 3
│   ├── network/              # Cliente HTTP
│   │   ├── dio_client.dart   # Cliente Dio configurado
│   │   ├── api_endpoints.dart # Endpoints del API
│   │   └── api_error.dart    # Manejo de errores
│   ├── storage/              # Almacenamiento
│   │   ├── secure_storage.dart  # Tokens y datos sensibles
│   │   └── local_storage.dart   # Caché con Hive
│   └── utils/                # Utilidades
│       ├── validators.dart   # Validadores de formularios
│       └── date_formatter.dart # Formateo de fechas
├── features/                 # Features por módulo
│   ├── auth/                # Autenticación
│   │   ├── data/           # Modelos y repositorios
│   │   ├── domain/         # Entidades e interfaces
│   │   └── presentation/   # UI y providers
│   ├── reclamos/           # Gestión de reclamos
│   ├── notificaciones/     # Notificaciones
│   └── perfil/             # Perfil de usuario
└── shared/                  # Widgets compartidos
    └── widgets/
```

## Requisitos Previos

- Flutter SDK 3.3.0 o superior
- Dart 3.0.0 o superior
- Android Studio / Xcode (para emuladores)
- Backend corriendo en http://localhost:3000/api/v1

## Instalación

### 1. Clonar el repositorio

```bash
cd "D:\aplicacion de reclamos telecomunicasiones rene\app-movil"
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Generar código (freezed, json_serializable)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configurar el backend

Asegúrate de que el backend esté corriendo en `http://localhost:3000/api/v1`. Si usas una URL diferente, actualiza `lib/core/config/app_config.dart`:

```dart
static const String baseUrl = 'http://TU_IP:3000/api/v1';
```

**IMPORTANTE para Android Emulator:**
- Usar `http://10.0.2.2:3000/api/v1` en lugar de `localhost`

**IMPORTANTE para dispositivos físicos:**
- Usar la IP de tu red local (ej: `http://192.168.1.100:3000/api/v1`)

### 5. Ejecutar la aplicación

```bash
# Verificar dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release
```

## Configuración de OneSignal (Notificaciones Push)

1. Crear cuenta en [OneSignal](https://onesignal.com/)
2. Crear una nueva app y obtener el App ID
3. Actualizar `lib/core/config/app_config.dart`:

```dart
static const String oneSignalAppId = 'TU_ONESIGNAL_APP_ID';
```

4. Configurar Android (`android/app/build.gradle`):

```gradle
plugins {
    id "com.onesignal.androidsdk.onesignal-gradle-plugin" version "0.14.0"
}
```

5. Configurar iOS (`ios/Runner/Info.plist`) - agregar permisos de notificaciones

## Estructura de Datos

### Estados de Reclamo
- `ABIERTO` - Recién creado
- `ASIGNADO` - Asignado a un técnico
- `EN_CURSO` - En proceso de resolución
- `EN_REVISION` - En revisión
- `CERRADO` - Resuelto y cerrado
- `RECHAZADO` - Rechazado

### Prioridades
- `BAJA` - Prioridad baja
- `MEDIA` - Prioridad media
- `ALTA` - Prioridad alta
- `URGENTE` - Urgente

### Categorías
- `INTERNET_ADSL` - Internet ADSL
- `INTERNET_FIBRA` - Internet Fibra
- `TELEFONO_ADSL` - Teléfono ADSL
- `TELEFONO_FIBRA` - Teléfono Fibra
- `TV_SENSA` - TV Sensa

### Roles de Usuario
- `PROFESIONAL` - Usuario estándar
- `TECNICO` - Técnico de campo
- `SUPERVISOR` - Supervisor de técnicos
- `ADMINISTRADOR` - Administrador del sistema

## API Integration

La app se conecta a los siguientes endpoints:

### Autenticación
- `POST /auth/register` - Registro de usuario
- `POST /auth/login` - Login
- `POST /auth/refresh` - Refresh token
- `POST /auth/change-password` - Cambiar contraseña
- `POST /auth/logout` - Logout

### Usuario
- `GET /usuarios/me` - Obtener perfil
- `PATCH /usuarios/me` - Actualizar perfil

### Reclamos
- `GET /reclamos` - Listar reclamos (con filtros)
- `POST /reclamos` - Crear reclamo
- `GET /reclamos/:id` - Obtener detalle
- `PATCH /reclamos/:id` - Actualizar reclamo
- `DELETE /reclamos/:id` - Eliminar reclamo
- `POST /reclamos/:id/comentarios` - Agregar comentario
- `GET /reclamos/:id/archivos` - Listar archivos
- `POST /reclamos/:id/archivos` - Subir archivo

### Notificaciones
- `GET /notificaciones` - Listar notificaciones
- `PATCH /notificaciones/:id/leer` - Marcar como leída
- `PATCH /notificaciones/marcar-todas-leidas` - Marcar todas como leídas

## Dependencias Principales

```yaml
# State Management
flutter_riverpod: ^2.5.1

# Navigation
go_router: ^14.0.0

# Network
dio: ^5.4.0
retrofit: ^4.0.0

# Storage
flutter_secure_storage: ^9.0.0
hive: ^2.2.3

# JSON & Code Generation
json_annotation: ^4.8.1
freezed_annotation: ^2.4.1

# UI
cached_network_image: ^3.3.1
intl: ^0.19.0

# Utils
equatable: ^2.0.5
dartz: ^0.10.1
```

## Características Implementadas

### Core
- [x] Configuración de la aplicación
- [x] Cliente HTTP con Dio
- [x] Interceptor de autenticación
- [x] Refresh automático de tokens
- [x] Manejo de errores centralizado
- [x] Almacenamiento seguro
- [x] Caché local con Hive
- [x] Validadores de formularios
- [x] Formateo de fechas
- [x] Tema claro y oscuro

### Autenticación
- [x] Login
- [x] Registro
- [x] Logout
- [x] Cambio de contraseña
- [x] Persistencia de sesión
- [x] Refresh automático de tokens
- [x] Guards de navegación

### Reclamos
- [ ] Listar reclamos
- [ ] Filtrar por estado, categoría, prioridad
- [ ] Ver detalle de reclamo
- [ ] Crear reclamo
- [ ] Editar reclamo
- [ ] Eliminar reclamo
- [ ] Agregar comentarios
- [ ] Subir archivos adjuntos
- [ ] Ver historial de cambios

### Notificaciones
- [ ] Listar notificaciones
- [ ] Marcar como leída
- [ ] Filtrar por tipo
- [ ] Push notifications con OneSignal

### Perfil
- [ ] Ver perfil de usuario
- [ ] Editar perfil
- [ ] Cambiar contraseña
- [ ] Configuración de tema
- [ ] Cerrar sesión

## Próximos Pasos

### Fase 1: Completar Reclamos (Prioritario)
1. Implementar `ReclamosListScreen` con filtros
2. Implementar `ReclamoDetailScreen` con comentarios
3. Implementar `CreateReclamoScreen` con validación
4. Implementar subida de archivos
5. Agregar pull-to-refresh
6. Implementar caché offline

### Fase 2: Notificaciones
1. Implementar `NotificacionesListScreen`
2. Integrar OneSignal
3. Configurar push notifications
4. Implementar badge de notificaciones no leídas

### Fase 3: Perfil
1. Implementar `PerfilScreen`
2. Implementar `EditPerfilScreen`
3. Implementar `ChangePasswordScreen`
4. Agregar configuración de tema
5. Agregar estadísticas de usuario

### Fase 4: Mejoras UI/UX
1. Animaciones de transición
2. Skeleton loaders
3. Empty states personalizados
4. Error states mejorados
5. Splash screen animado
6. Onboarding para nuevos usuarios

### Fase 5: Testing
1. Unit tests para repositorios
2. Widget tests para pantallas
3. Integration tests
4. Golden tests para UI consistency

## Comandos Útiles

```bash
# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Generar código en modo watch
flutter pub run build_runner watch

# Limpiar el proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Ejecutar tests
flutter test

# Construir APK
flutter build apk --release

# Construir App Bundle
flutter build appbundle --release

# Construir para iOS
flutter build ios --release
```

## Solución de Problemas

### Error de conexión al backend

Si obtienes errores de conexión:

1. **Android Emulator**: Usa `http://10.0.2.2:3000/api/v1`
2. **iOS Simulator**: Usa `http://localhost:3000/api/v1`
3. **Dispositivo físico**: Usa la IP local `http://192.168.x.x:3000/api/v1`

### Error de certificado SSL

Para desarrollo local, puedes deshabilitar la verificación SSL (solo desarrollo):

```dart
// En dio_client.dart
(_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    (HttpClient client) {
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  return client;
};
```

### Error de generación de código

Si los archivos `.g.dart` o `.freezed.dart` no se generan:

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Notas de Desarrollo

### Convenciones de Código

- Usar `const` cuando sea posible
- Preferir `final` sobre `var`
- Usar comillas simples para strings
- Seguir las guías de estilo de Dart
- Documentar métodos públicos
- Mantener archivos bajo 300 líneas

### Git Workflow

```bash
# Feature branch
git checkout -b feature/nombre-feature

# Commit con mensaje descriptivo
git commit -m "feat: agregar pantalla de reclamos"

# Push y crear PR
git push origin feature/nombre-feature
```

## Recursos

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Freezed Documentation](https://pub.dev/packages/freezed)

## Licencia

Este proyecto es privado y confidencial.

## Contacto

Para preguntas o soporte, contacta al equipo de desarrollo.

---

**Desarrollado con Flutter & Riverpod** 💙
