# Configuración de OneSignal

Esta guía te ayudará a configurar OneSignal para las notificaciones push en la aplicación móvil.

## Requisitos Previos

1. Cuenta de OneSignal (gratuita): https://onesignal.com/
2. Proyecto configurado en OneSignal
3. Credenciales de Firebase (para Android)
4. Certificado APNs (para iOS)

## Pasos de Configuración

### 1. Crear Proyecto en OneSignal

1. Ir a https://onesignal.com/ y crear una cuenta
2. Crear una nueva app en el dashboard de OneSignal
3. Seleccionar "Mobile App"
4. Seguir el asistente de configuración

### 2. Configurar Android (Firebase)

#### 2.1 Configurar Firebase Cloud Messaging

1. Ir a https://console.firebase.google.com/
2. Crear un nuevo proyecto o usar uno existente
3. Ir a **Project Settings** → **Cloud Messaging**
4. Copiar el **Server Key** y el **Sender ID**

#### 2.2 Agregar Credenciales a OneSignal

1. En OneSignal Dashboard → **Settings** → **Platforms**
2. Seleccionar **Google Android (FCM)**
3. Pegar el **Server Key** y **Sender ID**
4. Guardar

#### 2.3 Configurar App Android

Agregar el archivo `google-services.json` a:
```
android/app/google-services.json
```

En `android/app/build.gradle`, verificar:
```gradle
android {
    ...
    defaultConfig {
        applicationId "com.reclamostelco.app" // Tu package name
        ...
    }
}
```

### 3. Configurar iOS (APNs)

#### 3.1 Crear Certificado APNs

1. Ir a https://developer.apple.com/account/
2. Navegar a **Certificates, Identifiers & Profiles**
3. Crear un nuevo certificado de tipo **Apple Push Notification service SSL**
4. Descargar el certificado `.p12`

#### 3.2 Agregar Certificado a OneSignal

1. En OneSignal Dashboard → **Settings** → **Platforms**
2. Seleccionar **Apple iOS (APNs)**
3. Subir el certificado `.p12`
4. Ingresar la contraseña del certificado
5. Seleccionar el entorno (Development/Production)
6. Guardar

#### 3.3 Configurar Xcode

1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Seleccionar el target "Runner"
3. Ir a **Signing & Capabilities**
4. Agregar capability: **Push Notifications**
5. Agregar capability: **Background Modes**
   - Marcar: "Remote notifications"

### 4. Obtener OneSignal App IDs

1. En OneSignal Dashboard → **Settings** → **Keys & IDs**
2. Copiar el **OneSignal App ID**
3. Crear un App ID para cada entorno (dev, staging, prod)

### 5. Configurar App IDs en el Código

Editar `lib/core/config/app_config.dart`:

```dart
static String get oneSignalAppId {
  switch (_currentEnvironment) {
    case Environment.development:
      return 'tu-dev-app-id-aqui';
    case Environment.staging:
      return 'tu-staging-app-id-aqui';
    case Environment.production:
      return 'tu-prod-app-id-aqui';
  }
}
```

## Permisos Requeridos

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>

    <application>
        <!-- OneSignal configurado automáticamente por el plugin -->
    </application>
</manifest>
```

### iOS (`ios/Runner/Info.plist`)

Ya configurado por el plugin de OneSignal.

## Probar Notificaciones

### 1. Desde OneSignal Dashboard

1. Ir a **Messages** → **New Push**
2. Escribir el mensaje
3. Seleccionar **Send to Test Device**
4. Ingresar el Player ID (lo ves en Settings de la app)
5. Enviar

### 2. Desde la App

El Player ID se muestra en:
- **Perfil** → **Configuración** → **ID del Dispositivo**

Copia este ID y úsalo para enviar notificaciones de prueba desde el dashboard.

## Funcionalidades Implementadas

### En la App

✅ Inicialización automática de OneSignal
✅ Solicitud de permisos de notificación
✅ Sincronización de User ID con auth
✅ Tags para segmentación (user_id, email, rol)
✅ Opt-in / Opt-out de notificaciones
✅ Manejo de notificaciones recibidas
✅ Manejo de notificaciones abiertas
✅ Limpieza de notificaciones
✅ Toggle de notificaciones en Settings

### Desde el Backend

Para enviar notificaciones desde el backend NestJS:

```typescript
import * as OneSignal from 'onesignal-node';

const client = new OneSignal.Client({
  userAuthKey: 'YOUR_USER_AUTH_KEY',
  app: {
    appAuthKey: 'YOUR_APP_AUTH_KEY',
    appId: 'YOUR_APP_ID',
  },
});

// Enviar notificación a un usuario específico
await client.createNotification({
  contents: { en: 'Tu reclamo ha sido actualizado' },
  include_external_user_ids: [userId],
  data: {
    reclamoId: '123',
    tipo: 'actualizacion',
  },
});
```

## Segmentación de Usuarios

Los usuarios están etiquetados con:

| Tag | Descripción | Ejemplo |
|-----|-------------|---------|
| `user_id` | ID del usuario | "user_123" |
| `email` | Email del usuario | "juan@example.com" |
| `rol` | Rol del usuario | "PROFESIONAL" |

Puedes usar estos tags para enviar notificaciones segmentadas:

```typescript
// Notificar solo a técnicos
await client.createNotification({
  contents: { en: 'Nuevo reclamo asignado' },
  filters: [{ field: 'tag', key: 'rol', relation: '=', value: 'TECNICO' }],
});
```

## Eventos de Notificación

### Notificación Recibida (App en foreground)

```dart
ref.read(pushNotificationProvider).notificationReceived.listen((notification) {
  print('Notificación recibida: ${notification.title}');
  // Mostrar snackbar, actualizar UI, etc.
});
```

### Notificación Abierta

```dart
ref.read(pushNotificationProvider).notificationOpened.listen((openedResult) {
  print('Notificación abierta: ${openedResult.notification.notificationId}');
  final data = openedResult.notification.additionalData;

  // Navegar a la pantalla correspondiente
  if (data?['reclamoId'] != null) {
    context.push('/reclamos/${data['reclamoId']}');
  }
});
```

## Solución de Problemas

### Android: Notificaciones no llegan

1. Verificar que `google-services.json` esté en el lugar correcto
2. Verificar que el Server Key en OneSignal sea correcto
3. Verificar que los permisos estén en el Manifest
4. Limpiar y rebuilder: `flutter clean && flutter pub get && flutter run`

### iOS: Notificaciones no llegan

1. Verificar que el certificado APNs sea válido
2. Verificar que el Bundle ID coincida
3. Verificar que Push Notifications esté habilitado en Capabilities
4. Usar un dispositivo real (notificaciones no funcionan en simulador)
5. Verificar que el certificado sea para el entorno correcto (dev/prod)

### Player ID es null

1. Esperar a que OneSignal se inicialice completamente
2. Verificar que los permisos estén otorgados
3. Revisar logs de OneSignal en consola
4. Reiniciar la app

## Mejores Prácticas

1. **Permisos**: Solicitar permisos en el momento adecuado, no al inicio
2. **Segmentación**: Usar tags para enviar notificaciones relevantes
3. **Data Payload**: Incluir datos para deep linking
4. **Testing**: Probar en dispositivos reales antes de producción
5. **Opt-out**: Siempre permitir que usuarios desactiven notificaciones
6. **Analytics**: Monitorear tasas de apertura en OneSignal Dashboard

## Recursos Adicionales

- Documentación OneSignal: https://documentation.onesignal.com/
- Plugin Flutter: https://pub.dev/packages/onesignal_flutter
- Dashboard OneSignal: https://app.onesignal.com/
- Stack Overflow Tag: https://stackoverflow.com/questions/tagged/onesignal

## Soporte

Si tienes problemas, contacta a:
- Email: dev-soporte@reclamostelco.com
- OneSignal Support: https://onesignal.com/support
