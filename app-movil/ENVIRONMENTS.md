# Configuración de Entornos

Esta aplicación soporta múltiples entornos: **Development**, **Staging**, y **Production**.

## Cambiar de Entorno

Para cambiar el entorno de la aplicación, edita el archivo:
```
lib/core/config/app_config.dart
```

Encuentra la línea:
```dart
static const Environment _currentEnvironment = Environment.development;
```

Y cámbiala a uno de los siguientes valores:

### Development (Desarrollo)
```dart
static const Environment _currentEnvironment = Environment.development;
```
- **API URL**: `http://localhost:3000/api/v1`
- **Logging**: Habilitado
- **Debug Mode**: Habilitado
- **Analytics**: Deshabilitado
- **Crash Reporting**: Deshabilitado

### Staging (Pruebas)
```dart
static const Environment _currentEnvironment = Environment.staging;
```
- **API URL**: `https://staging-api.reclamostelco.com/api/v1`
- **Logging**: Habilitado
- **Debug Mode**: Deshabilitado
- **Analytics**: Deshabilitado
- **Crash Reporting**: Habilitado

### Production (Producción)
```dart
static const Environment _currentEnvironment = Environment.production;
```
- **API URL**: `https://api.reclamostelco.com/api/v1`
- **Logging**: Deshabilitado
- **Debug Mode**: Deshabilitado
- **Analytics**: Habilitado
- **Crash Reporting**: Habilitado

## Configuración por Entorno

Cada entorno tiene su propia configuración:

### API Base URLs
- **Development**: `http://localhost:3000/api/v1`
- **Staging**: `https://staging-api.reclamostelco.com/api/v1`
- **Production**: `https://api.reclamostelco.com/api/v1`

### OneSignal App IDs
Debes configurar los App IDs de OneSignal en `app_config.dart`:

```dart
static String get oneSignalAppId {
  switch (_currentEnvironment) {
    case Environment.development:
      return 'YOUR_DEV_ONESIGNAL_APP_ID';
    case Environment.staging:
      return 'YOUR_STAGING_ONESIGNAL_APP_ID';
    case Environment.production:
      return 'YOUR_PROD_ONESIGNAL_APP_ID';
  }
}
```

### Support Emails
- **Development**: `dev-soporte@reclamostelco.com`
- **Staging**: `staging-soporte@reclamostelco.com`
- **Production**: `soporte@reclamostelco.com`

## Feature Flags

Los feature flags se activan/desactivan automáticamente según el entorno:

| Feature | Development | Staging | Production |
|---------|------------|---------|------------|
| Debug Mode | ✅ | ❌ | ❌ |
| Logging | ✅ | ✅ | ❌ |
| Analytics | ❌ | ❌ | ✅ |
| Crash Reporting | ❌ | ✅ | ✅ |

## Verificar el Entorno Actual

Puedes verificar el entorno actual en la aplicación:

1. Ir a **Perfil** → **Configuración**
2. Ver la sección "Información de la App"
3. El campo "Ambiente" mostrará: `DEVELOPMENT`, `STAGING`, o `PRODUCTION`

## Mejores Prácticas

### Antes de Compilar para Production:

1. ✅ Cambiar entorno a `Environment.production`
2. ✅ Configurar correctamente los OneSignal App IDs
3. ✅ Verificar que las URLs de API sean correctas
4. ✅ Probar en staging antes de desplegar a producción
5. ✅ Verificar que los logs estén deshabilitados
6. ✅ Verificar que Analytics esté habilitado

### Comandos de Build:

```bash
# Development
flutter run --debug

# Staging
flutter run --profile

# Production
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

## Configuración Avanzada

Si necesitas más control sobre las configuraciones, puedes:

1. Usar `--dart-define` para pasar variables en tiempo de compilación
2. Crear archivos `.env` separados
3. Usar paquetes como `flutter_dotenv` o `envied`

Ejemplo con dart-define:
```bash
flutter run --dart-define=ENVIRONMENT=production
```

Y en el código:
```dart
static const Environment _currentEnvironment =
    String.fromEnvironment('ENVIRONMENT') == 'production'
        ? Environment.production
        : Environment.development;
```

## Notas Importantes

⚠️ **Nunca comitees API keys o secretos en el código**
- Los OneSignal App IDs deben ser configurados en CI/CD
- Usar variables de entorno para información sensible
- Mantener las claves de producción fuera del control de versiones

⚠️ **Limpieza antes de cambiar entornos**
```bash
flutter clean
flutter pub get
```

⚠️ **Storage separado por entorno**
Considera usar diferentes nombres de Hive boxes por entorno:
```dart
static String get reclamosBoxName => 'reclamos_box_${environment}';
```
