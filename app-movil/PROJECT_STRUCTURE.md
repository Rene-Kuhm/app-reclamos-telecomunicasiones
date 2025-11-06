# Project Structure - Reclamos Telco Flutter App

## Overview

Este documento describe la estructura completa del proyecto Flutter siguiendo los principios de Clean Architecture.

## Architecture Principles

### Clean Architecture Layers

1. **Presentation Layer** - UI, Widgets, State Management
2. **Domain Layer** - Entities, Use Cases, Repository Interfaces
3. **Data Layer** - Models, Repository Implementations, Data Sources

### Dependency Rule

- Las capas internas no conocen las capas externas
- Las dependencias fluyen hacia adentro (Presentation → Domain ← Data)
- El dominio es independiente de frameworks y detalles de implementación

---

## Directory Structure

```
app-movil/
├── .gitignore                      # Git ignore rules
├── .metadata                       # Flutter metadata
├── analysis_options.yaml           # Dart analyzer configuration
├── pubspec.yaml                    # Dependencies and metadata
├── README.md                       # Project documentation
├── SETUP_GUIDE.md                  # Detailed setup instructions
├── PROJECT_STRUCTURE.md            # This file
│
├── android/                        # Android native code (generated)
│   ├── app/
│   │   ├── src/
│   │   └── build.gradle
│   ├── gradle/
│   └── build.gradle
│
├── ios/                           # iOS native code (generated)
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   └── Runner.xcworkspace/
│
├── lib/                           # Main Dart code
│   ├── main.dart                  # App entry point
│   │
│   ├── core/                      # Core functionality (shared across features)
│   │   ├── config/
│   │   │   ├── app_config.dart              # App configuration constants
│   │   │   ├── router.dart                  # Navigation with go_router
│   │   │   └── theme.dart                   # Material 3 theme configuration
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart              # Dio HTTP client setup
│   │   │   ├── api_endpoints.dart           # API endpoint constants
│   │   │   └── api_error.dart               # Error handling utilities
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage.dart          # Secure storage (tokens)
│   │   │   └── local_storage.dart           # Local cache with Hive
│   │   │
│   │   └── utils/
│   │       ├── validators.dart              # Form validators
│   │       └── date_formatter.dart          # Date formatting utilities
│   │
│   ├── features/                  # Feature-based modules
│   │   │
│   │   ├── auth/                 # Authentication feature
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── login_request.dart           # Login request DTO
│   │   │   │   │   ├── login_request.freezed.dart   # Generated
│   │   │   │   │   ├── login_request.g.dart         # Generated
│   │   │   │   │   ├── register_request.dart        # Register request DTO
│   │   │   │   │   ├── register_request.freezed.dart
│   │   │   │   │   ├── register_request.g.dart
│   │   │   │   │   ├── auth_response.dart           # Auth response DTO
│   │   │   │   │   ├── auth_response.freezed.dart
│   │   │   │   │   ├── auth_response.g.dart
│   │   │   │   │   ├── user_model.dart              # User model (data)
│   │   │   │   │   ├── user_model.freezed.dart
│   │   │   │   │   └── user_model.g.dart
│   │   │   │   │
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository_impl.dart    # Auth repo implementation
│   │   │   │   │
│   │   │   │   └── datasources/
│   │   │   │       └── auth_remote_datasource.dart  # Remote API calls
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart                    # User entity (domain)
│   │   │   │   │
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart         # Auth repo interface
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart           # Riverpod state management
│   │   │       │
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart            # Login UI
│   │   │       │   └── register_screen.dart         # Register UI (to be completed)
│   │   │       │
│   │   │       └── widgets/
│   │   │           ├── custom_text_field.dart       # Reusable text field
│   │   │           └── loading_button.dart          # Button with loading state
│   │   │
│   │   ├── reclamos/             # Claims management feature
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── reclamo_model.dart           # Reclamo model (to implement)
│   │   │   │   │   ├── create_reclamo_request.dart  # Create DTO (to implement)
│   │   │   │   │   └── update_reclamo_request.dart  # Update DTO (to implement)
│   │   │   │   │
│   │   │   │   ├── repositories/
│   │   │   │   │   └── reclamos_repository_impl.dart (to implement)
│   │   │   │   │
│   │   │   │   └── datasources/
│   │   │   │       └── reclamos_remote_datasource.dart (to implement)
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── reclamo.dart                 # Reclamo entity
│   │   │   │   │
│   │   │   │   └── repositories/
│   │   │   │       └── reclamos_repository.dart     (to implement)
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── reclamos_provider.dart       (to implement)
│   │   │       │
│   │   │       ├── screens/
│   │   │       │   ├── reclamos_list_screen.dart    (to implement)
│   │   │       │   ├── reclamo_detail_screen.dart   (to implement)
│   │   │       │   └── create_reclamo_screen.dart   (to implement)
│   │   │       │
│   │   │       └── widgets/
│   │   │           ├── reclamo_card.dart            (to implement)
│   │   │           └── estado_chip.dart             (to implement)
│   │   │
│   │   ├── notificaciones/       # Notifications feature
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── datasources/
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── repositories/
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   │
│   │   └── perfil/               # User profile feature
│   │       ├── data/
│   │       │   ├── models/
│   │       │   ├── repositories/
│   │       │   └── datasources/
│   │       │
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   └── repositories/
│   │       │
│   │       └── presentation/
│   │           ├── providers/
│   │           ├── screens/
│   │           └── widgets/
│   │
│   └── shared/                   # Shared widgets across features
│       └── widgets/
│           ├── app_bar_custom.dart          (to implement)
│           ├── loading_indicator.dart       (to implement)
│           └── error_widget.dart            (to implement)
│
├── test/                         # Unit and widget tests
│   └── widget_test.dart
│
└── assets/                       # Static assets (to be added)
    ├── images/
    ├── icons/
    └── fonts/
```

---

## Feature Module Structure

Cada feature sigue la misma estructura de Clean Architecture:

```
feature_name/
├── data/                         # Data layer
│   ├── models/                   # DTOs, data models
│   │   └── model_name.dart       # With freezed & json_serializable
│   ├── repositories/             # Repository implementations
│   │   └── repository_impl.dart
│   └── datasources/              # Remote/Local data sources
│       ├── remote_datasource.dart
│       └── local_datasource.dart (optional)
│
├── domain/                       # Domain layer (business logic)
│   ├── entities/                 # Pure Dart entities
│   │   └── entity_name.dart      # With equatable
│   └── repositories/             # Repository interfaces
│       └── repository.dart
│
└── presentation/                 # Presentation layer (UI)
    ├── providers/                # Riverpod state management
    │   └── feature_provider.dart
    ├── screens/                  # Full screen pages
    │   └── screen_name.dart
    └── widgets/                  # Feature-specific widgets
        └── widget_name.dart
```

---

## Core Components

### Config
- **app_config.dart**: Constantes de configuración (URLs, timeouts, keys)
- **router.dart**: Configuración de rutas con go_router y guards de auth
- **theme.dart**: Tema Material 3 (light/dark)

### Network
- **dio_client.dart**: Cliente HTTP con interceptores para auth y logging
- **api_endpoints.dart**: Constantes de endpoints del API
- **api_error.dart**: Clases de error y manejo centralizado

### Storage
- **secure_storage.dart**: Almacenamiento seguro (tokens, credenciales)
- **local_storage.dart**: Caché local con Hive (reclamos, notificaciones)

### Utils
- **validators.dart**: Validadores de formularios reutilizables
- **date_formatter.dart**: Utilidades de formateo de fechas

---

## State Management Strategy

### Riverpod Providers

1. **Provider**: Objetos inmutables (singletons)
   ```dart
   final dioClientProvider = Provider<DioClient>((ref) => DioClient());
   ```

2. **StateNotifierProvider**: Estado mutable con lógica de negocio
   ```dart
   final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
   ```

3. **FutureProvider**: Operaciones asíncronas
   ```dart
   final reclamosProvider = FutureProvider<List<Reclamo>>(...);
   ```

4. **StreamProvider**: Flujos de datos en tiempo real
   ```dart
   final notificacionesStreamProvider = StreamProvider<List<Notificacion>>(...);
   ```

---

## Data Flow

### Example: Login Flow

```
LoginScreen (Presentation)
    ↓ User taps "Login"
AuthProvider (Presentation)
    ↓ calls login()
AuthRepository (Domain Interface)
    ↓ implemented by
AuthRepositoryImpl (Data)
    ↓ calls
AuthRemoteDataSource (Data)
    ↓ uses
DioClient (Core)
    ↓ sends HTTP request
Backend API
    ↓ returns response
AuthRemoteDataSource
    ↓ parses to
UserModel (Data)
    ↓ converts to
User Entity (Domain)
    ↓ returns via Either<Failure, User>
AuthProvider
    ↓ updates state
LoginScreen
    ↓ navigates to HomeScreen
```

---

## Code Generation

### Files That Require Generation

- **Freezed** (immutable models): `*.freezed.dart`
- **JSON Serialization**: `*.g.dart`

### Commands

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## Testing Strategy

### Test Structure (to be implemented)

```
test/
├── unit/
│   ├── core/
│   │   ├── network/
│   │   └── utils/
│   └── features/
│       ├── auth/
│       └── reclamos/
│
├── widget/
│   ├── auth/
│   └── reclamos/
│
└── integration/
    └── flows/
```

### Types of Tests

1. **Unit Tests**: Logic, repositories, providers
2. **Widget Tests**: Individual widgets
3. **Integration Tests**: Complete user flows
4. **Golden Tests**: Visual regression testing

---

## Build Configurations

### Debug Build
```bash
flutter run
# Hot reload enabled
# Debug logging enabled
# Larger app size
```

### Release Build
```bash
flutter build apk --release
# Optimized code
# Minified
# Obfuscated
```

### Build Flavors (future enhancement)

- **Development**: Local backend
- **Staging**: Staging backend
- **Production**: Production backend

---

## Dependencies Overview

### Core Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| flutter_riverpod | State management | ^2.5.1 |
| go_router | Navigation | ^14.0.0 |
| dio | HTTP client | ^5.4.0 |
| flutter_secure_storage | Secure storage | ^9.0.0 |
| hive | Local database | ^2.2.3 |

### Code Generation

| Package | Purpose |
|---------|---------|
| freezed | Immutable models |
| json_serializable | JSON serialization |
| build_runner | Code generation |

### Utilities

| Package | Purpose |
|---------|---------|
| equatable | Value equality |
| dartz | Functional programming |
| intl | Internationalization |
| cached_network_image | Image caching |

---

## File Naming Conventions

### General Rules
- **Snake case**: `user_model.dart`, `auth_provider.dart`
- **Descriptive names**: `create_reclamo_request.dart` (not just `request.dart`)
- **Suffixes**:
  - `_screen.dart` for screens
  - `_widget.dart` for reusable widgets
  - `_provider.dart` for Riverpod providers
  - `_repository.dart` for repositories
  - `_model.dart` for data models

### Class Naming
- **PascalCase**: `UserModel`, `AuthProvider`, `LoginScreen`
- **Descriptive**: Match file name in PascalCase

### Constants
- **lowerCamelCase** for variables: `baseUrl`, `defaultTimeout`
- **SCREAMING_SNAKE_CASE** for compile-time constants: `API_KEY`

---

## Current Implementation Status

### ✅ Completed

#### Core
- [x] App configuration
- [x] Theme (light/dark)
- [x] Router with auth guards
- [x] Dio client with interceptors
- [x] Token refresh interceptor
- [x] Error handling
- [x] Secure storage
- [x] Local storage (Hive)
- [x] Form validators
- [x] Date formatters

#### Auth Feature
- [x] Domain entities
- [x] Data models (with freezed)
- [x] Repository interface
- [x] Repository implementation
- [x] Remote data source
- [x] Auth provider (Riverpod)
- [x] Login screen
- [x] Custom widgets (TextField, Button)

#### Reclamos Feature
- [x] Domain entity (Reclamo)
- [ ] Data models
- [ ] Repository implementation
- [ ] Providers
- [ ] Screens (list, detail, create)

### 🚧 To Be Implemented

#### High Priority
1. Complete Reclamos feature
2. Notificaciones feature
3. Perfil feature
4. Register screen completion
5. Home screen with navigation

#### Medium Priority
1. Shared widgets library
2. Pull-to-refresh
3. Pagination
4. File upload
5. Image picker integration

#### Low Priority
1. OneSignal integration
2. Advanced filters
3. Search functionality
4. Settings screen
5. About screen

---

## Best Practices

### Code Style
1. Follow Dart style guide
2. Use `const` constructors when possible
3. Prefer `final` over `var`
4. Use single quotes for strings
5. Keep files under 300 lines
6. Add documentation for public APIs

### Architecture
1. Keep domain layer framework-independent
2. Use dependency injection (Riverpod)
3. Follow SOLID principles
4. Use Either<Failure, Success> for error handling
5. Separate UI logic from business logic

### Performance
1. Use `const` widgets
2. Implement list virtualization
3. Cache network images
4. Lazy load data
5. Use Hive for offline support

### Security
1. Never commit API keys
2. Use flutter_secure_storage for tokens
3. Validate all user input
4. Sanitize data before display
5. Use HTTPS in production

---

## Next Steps for Development

1. **Complete Reclamos Feature** (Highest Priority)
   - Implement data models with freezed
   - Create repository and data source
   - Build list screen with filters
   - Build detail screen
   - Build create/edit screen

2. **Implement Notificaciones**
   - Similar structure to Reclamos
   - Add real-time updates
   - Integrate OneSignal

3. **Build Perfil Module**
   - Display user info
   - Edit profile
   - Change password
   - Settings

4. **Enhance Navigation**
   - Bottom navigation bar
   - Drawer menu
   - Deep linking

5. **Add Tests**
   - Unit tests for repositories
   - Widget tests for screens
   - Integration tests for flows

---

## Maintenance Notes

### Updating Dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Update all to compatible versions
flutter pub upgrade

# Update to major versions (breaking changes)
flutter pub upgrade --major-versions
```

### Clean Build

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Regenerate Platform Code

If you modify native configurations:

```bash
# Android
cd android
./gradlew clean
cd ..

# iOS
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

---

## Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Riverpod Best Practices](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

---

**Last Updated:** 2025-11-06
**Flutter Version:** 3.16.0
**Dart Version:** 3.0.0
