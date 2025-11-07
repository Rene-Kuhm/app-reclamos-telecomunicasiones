# Testing Guide

Esta guía explica cómo ejecutar y escribir tests para la aplicación móvil Flutter.

## Tipos de Tests Implementados

### 1. Tests Unitarios (Unit Tests)
- **Ubicación**: `test/`
- **Propósito**: Probar lógica de negocio, validadores, entidades, y funciones puras
- **Archivos**:
  - `test/core/utils/validators_test.dart` - Tests de validaciones
  - `test/features/auth/domain/entities/user_test.dart` - Tests de entidad User
  - `test/features/reclamos/domain/entities/reclamo_test.dart` - Tests de entidad Reclamo

### 2. Tests de Widgets (Widget Tests)
- **Ubicación**: `test/features/*/presentation/widgets/`
- **Propósito**: Probar componentes UI individuales
- **Archivos**:
  - `test/features/auth/presentation/widgets/custom_text_field_test.dart` - Tests de CustomTextField

### 3. Tests de Providers (State Management Tests)
- **Ubicación**: `test/features/*/presentation/providers/`
- **Propósito**: Probar gestión de estado con Riverpod
- **Archivos**:
  - `test/features/auth/presentation/providers/auth_provider_test.dart` - Tests de AuthProvider

## Ejecutar Tests

### Ejecutar todos los tests
```bash
flutter test
```

### Ejecutar tests con coverage
```bash
flutter test --coverage
```

### Ver reporte de coverage en HTML
```bash
# Windows
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html

# Mac/Linux
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Ejecutar tests específicos
```bash
# Por archivo
flutter test test/core/utils/validators_test.dart

# Por patrón
flutter test test/features/auth/**/*_test.dart
```

### Ejecutar tests en modo watch
```bash
flutter test --watch
```

## Estructura de un Test

### Test Unitario Ejemplo

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
      });
    });
  });
}
```

### Widget Test Ejemplo

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil/features/auth/presentation/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField Widget', () {
    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: TextEditingController(),
              label: 'Test Label',
              hint: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });
  });
}
```

### Provider Test Ejemplo

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_movil/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    test('initial state should be unauthenticated', () {
      final container = ProviderContainer();
      final authState = container.read(authProvider);

      expect(authState.isAuthenticated, false);
      expect(authState.user, null);

      container.dispose();
    });
  });
}
```

## Coverage Actual

Tests implementados cubren:

✅ **Core Utilities**
- Validators (email, password, phone, name, required)

✅ **Domain Entities**
- User entity y role checks
- Reclamo entity y property checks

✅ **Presentation Layer**
- CustomTextField widget
- AuthProvider state management

## Agregar Más Tests

### Tests Pendientes (Recomendados)

#### Unit Tests:
1. `test/core/network/api_error_test.dart` - Tests de manejo de errores
2. `test/core/utils/date_formatter_test.dart` - Tests de formateo de fechas
3. `test/features/reclamos/data/models/reclamo_model_test.dart` - Tests de serialización

#### Widget Tests:
1. `test/features/auth/presentation/widgets/loading_button_test.dart`
2. `test/features/reclamos/presentation/widgets/reclamo_card_test.dart`
3. `test/features/reclamos/presentation/widgets/estado_chip_test.dart`

#### Integration Tests:
1. `integration_test/app_test.dart` - Tests de flujo completo
2. `integration_test/login_flow_test.dart` - Tests de login
3. `integration_test/reclamo_creation_test.dart` - Tests de crear reclamo

## Mejores Prácticas

### 1. Nombrado de Tests

```dart
// ✅ Bueno
test('should return null for valid email', () {});
test('should return error for empty email', () {});

// ❌ Malo
test('test1', () {});
test('email validation', () {});
```

### 2. Arrange-Act-Assert (AAA)

```dart
test('should update user on successful login', () {
  // Arrange
  final user = User(id: '1', nombre: 'John', ...);

  // Act
  final result = await authService.login('email', 'password');

  // Assert
  expect(result, isRight);
  expect(result.getOrElse(() => throw Exception()), user);
});
```

### 3. Usar Grupos para Organización

```dart
group('AuthProvider', () {
  group('login', () {
    test('should succeed with valid credentials', () {});
    test('should fail with invalid credentials', () {});
  });

  group('logout', () {
    test('should clear user data', () {});
    test('should clear tokens', () {});
  });
});
```

### 4. Mocking

Para tests que requieren dependencies, usar mocks:

```bash
flutter pub add --dev mockito
flutter pub add --dev build_runner
```

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  test('should call repository login', () async {
    // Arrange
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => Right(user));

    // Act
    await authNotifier.login('email', 'password');

    // Assert
    verify(mockRepository.login('email', 'password')).called(1);
  });
}
```

### 5. Widget Tests con Providers

```dart
testWidgets('should display user name', (tester) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith((ref) => MockAuthNotifier()),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: PerfilScreen(),
      ),
    ),
  );

  expect(find.text('John Doe'), findsOneWidget);
});
```

## Comandos Útiles

```bash
# Limpiar y ejecutar tests
flutter clean && flutter pub get && flutter test

# Tests en modo verbose
flutter test --verbose

# Tests con configuración específica
flutter test --dart-define=ENVIRONMENT=test

# Ver solo tests que fallan
flutter test --reporter expanded

# Ejecutar tests en dispositivo
flutter test --device-id <device_id>
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Debugging Tests

### Ver print statements
```bash
flutter test --verbose
```

### Pausar ejecución
```dart
test('my test', () async {
  debugger(); // Pausa aquí
  expect(true, true);
});
```

### Ver widget tree
```dart
testWidgets('test', (tester) async {
  await tester.pumpWidget(MyWidget());
  debugDumpApp(); // Imprime el árbol de widgets
});
```

## Resources

- Flutter Testing Docs: https://docs.flutter.dev/testing
- Effective Dart Testing: https://dart.dev/guides/language/effective-dart/testing
- Riverpod Testing: https://riverpod.dev/docs/cookbooks/testing
- Mockito: https://pub.dev/packages/mockito

## Métricas de Calidad

### Objetivos de Coverage
- **Mínimo**: 60% coverage
- **Objetivo**: 80% coverage
- **Excelente**: 90%+ coverage

### Áreas Críticas (100% coverage requerido)
- Validadores
- Modelos de datos
- Lógica de negocio (repositories, use cases)
- State management (providers, notifiers)

### Áreas de Menor Prioridad
- UI widgets simples
- Archivos de configuración
- Generated code (freezed, json_serializable)

## Notas Importantes

⚠️ **No commitear archivos de coverage**
Agregar a `.gitignore`:
```
coverage/
*.lcov
*.info
```

⚠️ **Ejecutar tests antes de cada commit**
Usar pre-commit hooks para automatizar

⚠️ **Tests deben ser independientes**
Cada test debe poder ejecutarse solo sin depender de otros

⚠️ **Tests deben ser rápidos**
Si un test tarda más de 5 segundos, considerar optimizarlo

## Soporte

Para dudas sobre testing:
- Email: dev-soporte@reclamostelco.com
- Documentación interna: [wiki link]
