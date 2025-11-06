# Setup Guide - Reclamos Telco Flutter App

Esta guía proporciona instrucciones paso a paso para configurar y ejecutar la aplicación Flutter.

## Tabla de Contenidos

1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Instalación de Flutter](#instalación-de-flutter)
3. [Configuración del Proyecto](#configuración-del-proyecto)
4. [Generación de Código](#generación-de-código)
5. [Configuración del Backend](#configuración-del-backend)
6. [Ejecución en Android](#ejecución-en-android)
7. [Ejecución en iOS](#ejecución-en-ios)
8. [Troubleshooting](#troubleshooting)

---

## Requisitos del Sistema

### Windows
- Windows 10 o superior (64-bit)
- Git para Windows
- Android Studio (o al menos Android SDK)
- Espacio en disco: mínimo 3 GB

### macOS
- macOS 10.14 (Mojave) o superior
- Xcode 13 o superior
- CocoaPods
- Espacio en disco: mínimo 3 GB

### Linux
- Sistema operativo de 64 bits
- Android Studio
- Dependencias de desarrollo

---

## Instalación de Flutter

### 1. Descargar Flutter SDK

**Windows:**
```bash
# Descargar desde: https://docs.flutter.dev/get-started/install/windows
# Extraer en C:\src\flutter

# Agregar al PATH:
# System Properties > Environment Variables > Path
# Agregar: C:\src\flutter\bin
```

**macOS:**
```bash
# Usando Homebrew
brew install flutter

# O descarga directamente:
cd ~/development
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip
unzip flutter_macos_3.16.0-stable.zip

# Agregar al PATH en ~/.zshrc o ~/.bash_profile
export PATH="$PATH:`pwd`/flutter/bin"
```

**Linux:**
```bash
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz

# Agregar al PATH en ~/.bashrc
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verificar la instalación

```bash
flutter doctor
```

Esto mostrará el estado de tu instalación. Resuelve cualquier problema indicado.

### 3. Instalar Android Studio (si aún no lo tienes)

1. Descargar desde: https://developer.android.com/studio
2. Instalar Android SDK (API 33 o superior)
3. Instalar Android SDK Command-line Tools
4. Instalar Android Emulator

### 4. Configurar Android Studio para Flutter

```bash
# Instalar plugins de Flutter y Dart
# Android Studio > Settings > Plugins > Marketplace
# Buscar "Flutter" e instalar (instalará Dart automáticamente)
```

---

## Configuración del Proyecto

### 1. Navegar al directorio del proyecto

```bash
cd "D:\aplicacion de reclamos telecomunicasiones rene\app-movil"
```

### 2. Instalar dependencias

```bash
flutter pub get
```

Esto descargará todas las dependencias especificadas en `pubspec.yaml`.

### 3. Verificar que el proyecto está correctamente configurado

```bash
flutter doctor -v
flutter analyze
```

---

## Generación de Código

El proyecto usa varios paquetes de generación de código (freezed, json_serializable, etc.).

### 1. Generar todos los archivos necesarios

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando generará:
- Archivos `.g.dart` (json_serializable)
- Archivos `.freezed.dart` (freezed)

### 2. Modo watch (opcional)

Si estás desarrollando activamente, puedes usar el modo watch para regenerar automáticamente:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

**NOTA IMPORTANTE:** Los archivos generados (`*.g.dart`, `*.freezed.dart`) ya deberían estar en el proyecto. Solo necesitas regenerarlos si:
- Modificas los modelos de datos
- Agregas nuevos modelos
- Hay errores de compilación relacionados con código generado

---

## Configuración del Backend

### 1. Verificar que el backend está corriendo

Asegúrate de que el backend Node.js esté ejecutándose:

```bash
# Desde el directorio del backend
cd "D:\aplicacion de reclamos telecomunicasiones rene\backend"
npm start
```

El backend debería estar disponible en: `http://localhost:3000/api/v1`

### 2. Configurar la URL del API

Edita `lib/core/config/app_config.dart`:

```dart
// Para Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

// Para iOS Simulator
static const String baseUrl = 'http://localhost:3000/api/v1';

// Para dispositivo físico (usa tu IP local)
static const String baseUrl = 'http://192.168.1.XXX:3000/api/v1';
```

### 3. Encontrar tu IP local (para dispositivos físicos)

**Windows:**
```bash
ipconfig
# Busca "IPv4 Address" en tu adaptador de red activo
```

**macOS/Linux:**
```bash
ifconfig
# Busca "inet" en tu interfaz de red (usualmente en0 o wlan0)
```

---

## Ejecución en Android

### Opción 1: Usando Android Emulator

1. **Crear un emulador (si no tienes uno):**

```bash
# Listar dispositivos disponibles
flutter emulators

# Crear un nuevo emulador desde Android Studio
# Tools > Device Manager > Create Device
# Selecciona un dispositivo (ej: Pixel 7) y una imagen del sistema (API 33+)
```

2. **Iniciar el emulador:**

```bash
flutter emulators --launch <emulator_id>

# O desde Android Studio:
# Tools > Device Manager > Play button
```

3. **Ejecutar la app:**

```bash
flutter run
```

### Opción 2: Usando un dispositivo físico Android

1. **Habilitar modo desarrollador en tu dispositivo:**
   - Ve a Configuración > Acerca del teléfono
   - Toca "Número de compilación" 7 veces
   - Vuelve y entra a "Opciones de desarrollador"
   - Habilita "Depuración USB"

2. **Conectar el dispositivo:**
   - Conecta tu dispositivo por USB
   - Acepta el diálogo de depuración USB en tu dispositivo

3. **Verificar conexión:**

```bash
flutter devices
# Deberías ver tu dispositivo listado
```

4. **Ejecutar la app:**

```bash
flutter run
```

### Compilar APK para distribución

```bash
# APK de debug
flutter build apk --debug

# APK de release
flutter build apk --release

# El APK estará en: build/app/outputs/flutter-apk/
```

---

## Ejecución en iOS

**NOTA:** Solo disponible en macOS

### 1. Instalar dependencias de iOS

```bash
cd ios
pod install
cd ..
```

### 2. Abrir en Xcode (opcional)

```bash
open ios/Runner.xcworkspace
```

### 3. Configurar el equipo de desarrollo

1. Abrir el proyecto en Xcode
2. Seleccionar el proyecto "Runner"
3. En la pestaña "Signing & Capabilities"
4. Seleccionar tu equipo de desarrollo

### 4. Ejecutar en simulador

```bash
# Listar simuladores disponibles
flutter emulators

# Abrir simulador
open -a Simulator

# Ejecutar la app
flutter run
```

### 5. Ejecutar en dispositivo físico iOS

1. Conectar tu iPhone/iPad por USB
2. Confiar en el dispositivo cuando se solicite
3. En Xcode, seleccionar tu dispositivo
4. Ejecutar:

```bash
flutter run
```

---

## Troubleshooting

### Error: "Flutter command not found"

**Solución:** Agrega Flutter al PATH del sistema

```bash
# Windows (PowerShell como administrador)
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", "User")

# macOS/Linux
echo 'export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Error: "Unable to connect to backend"

**Causas posibles:**

1. **Backend no está corriendo**
   ```bash
   # Inicia el backend
   cd backend
   npm start
   ```

2. **URL incorrecta en Android Emulator**
   - Usa `http://10.0.2.2:3000/api/v1` en lugar de `localhost`

3. **Firewall bloqueando la conexión**
   - Permite conexiones al puerto 3000 en tu firewall

4. **Dispositivo y PC en redes diferentes**
   - Asegúrate de que ambos estén en la misma red WiFi

### Error: "Build failed with exception"

```bash
# Limpiar el proyecto
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Error: "Gradle build failed" (Android)

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "CocoaPods not installed" (iOS)

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Error: "Certificate verification failed"

Para desarrollo local, puedes deshabilitar temporalmente la verificación SSL:

En `lib/core/network/dio_client.dart`, agrega:

```dart
// Solo para desarrollo
(_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    (HttpClient client) {
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  return client;
};
```

### Error: "Failed to generate code"

```bash
# Eliminar archivos generados anteriormente
flutter pub run build_runner clean

# Regenerar
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problemas de rendimiento en el emulador

1. **Habilitar aceleración de hardware:**
   - Instala Intel HAXM (Windows/macOS) o KVM (Linux)
   - En Android Studio: Tools > SDK Manager > SDK Tools > Intel x86 Emulator Accelerator

2. **Aumentar RAM del emulador:**
   - Device Manager > Edit Device > Advanced Settings
   - Aumentar RAM a 4GB o más

3. **Usar un dispositivo físico** (mejor rendimiento)

---

## Comandos Rápidos de Referencia

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Hot reload (durante ejecución)
# Presiona 'r' en la terminal

# Hot restart (durante ejecución)
# Presiona 'R' en la terminal

# Ver logs
flutter logs

# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Limpiar proyecto
flutter clean

# Construir APK
flutter build apk --release

# Construir App Bundle
flutter build appbundle --release

# Construir para iOS
flutter build ios --release

# Actualizar dependencias
flutter pub upgrade

# Ver información de Flutter
flutter doctor -v
```

---

## Próximos Pasos

Una vez que la app esté ejecutándose:

1. **Crear una cuenta de prueba:**
   - Usar la pantalla de registro
   - O usar credenciales predefinidas del backend

2. **Explorar las funcionalidades:**
   - Login/Logout
   - Ver la estructura del proyecto
   - Revisar el código de ejemplo

3. **Comenzar el desarrollo:**
   - Implementar las pantallas de reclamos
   - Agregar las funcionalidades de notificaciones
   - Personalizar el tema

---

## Recursos Adicionales

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

---

## Soporte

Si encuentras problemas no cubiertos en esta guía:

1. Revisa los logs de Flutter: `flutter logs`
2. Busca el error en [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Consulta [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)
4. Contacta al equipo de desarrollo

---

**Última actualización:** 2025-11-06
