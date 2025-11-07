# 🚀 Guía de Instalación y Ejecución Completa

## Sistema de Reclamos Telecomunicaciones

Esta guía te llevará paso a paso desde la instalación hasta tener la aplicación completa funcionando.

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación del Backend](#instalación-del-backend)
3. [Instalación de Flutter](#instalación-de-flutter)
4. [Configuración del Frontend](#configuración-del-frontend)
5. [Ejecución de la Aplicación](#ejecución-de-la-aplicación)
6. [Testing Completo](#testing-completo)
7. [Solución de Problemas](#solución-de-problemas)

---

## 1. Requisitos Previos

### Software Necesario

- **Node.js 18+** - [Descargar](https://nodejs.org/)
- **npm 9+** - Viene con Node.js
- **Git** - [Descargar](https://git-scm.com/)
- **PostgreSQL 15+** - Supabase (online) o local
- **Flutter SDK 3.24+** - [Descargar](https://flutter.dev/docs/get-started/install)
- **Android Studio** - Para emulador Android
- **VS Code** - Editor recomendado

### Verificar Instalaciones

```bash
node --version    # Debería ser v18+
npm --version     # Debería ser 9+
git --version     # Cualquier versión reciente
flutter --version # Debería ser 3.24+
```

---

## 2. Instalación del Backend

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/Rene-Kuhm/app-reclamos-telecomunicasiones.git
cd app-reclamos-telecomunicasiones
```

### Paso 2: Instalar Dependencias del Backend

```bash
cd backend
npm install
```

**Tiempo estimado:** 3-5 minutos

### Paso 3: Configurar Base de Datos

#### Opción A: Supabase (Recomendado)

1. Crear cuenta en [Supabase](https://supabase.com)
2. Crear nuevo proyecto
3. Copiar `Connection String` de Settings → Database

#### Opción B: PostgreSQL Local

```bash
# Windows (con Chocolatey)
choco install postgresql

# macOS
brew install postgresql@15
brew services start postgresql@15

# Linux
sudo apt install postgresql-15
sudo systemctl start postgresql
```

### Paso 4: Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env con tu editor favorito
# Windows:
notepad .env

# macOS/Linux:
nano .env
```

**Configuración mínima requerida:**

```env
# Base de Datos
DATABASE_URL="postgresql://usuario:password@host:5432/database?schema=public"

# JWT (Generar secretos seguros)
JWT_SECRET="tu-super-secreto-jwt-muy-largo-cambiar-esto"
JWT_REFRESH_SECRET="tu-super-secreto-refresh-jwt-muy-largo-cambiar-esto"

# Puerto
PORT=3000

# Frontend URL
FRONTEND_URL=http://localhost:5173
```

**💡 Tip:** Para generar secretos seguros:

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

### Paso 5: Inicializar Base de Datos

```bash
# Generar cliente Prisma
npm run prisma:generate

# Crear tablas
npm run prisma:migrate

# Poblar datos de prueba
npm run prisma:seed
```

**Usuarios de prueba creados:**

| Email | Password | Rol |
|-------|----------|-----|
| admin@reclamos.com | Password123! | ADMINISTRADOR |
| supervisor@reclamos.com | Password123! | SUPERVISOR |
| tecnico1@reclamos.com | Password123! | TECNICO |
| profesional1@reclamos.com | Password123! | PROFESIONAL |

### Paso 6: Iniciar Backend

```bash
# Desarrollo (con hot-reload)
npm run start:dev

# O en modo producción
npm run build
npm run start:prod
```

**✅ Backend corriendo en:** http://localhost:3000

**📚 Documentación API (Swagger):** http://localhost:3000/api

**🏥 Health Check:** http://localhost:3000/api/v1/health

---

## 3. Instalación de Flutter

### Windows

1. **Descargar Flutter SDK**
   - Ir a https://flutter.dev/docs/get-started/install/windows
   - Descargar el archivo ZIP
   - Extraer en `C:\src\flutter`

2. **Agregar a PATH**
   - Buscar "Variables de entorno" en Windows
   - Editar variable `Path`
   - Agregar `C:\src\flutter\bin`

3. **Instalar Android Studio**
   - Descargar de https://developer.android.com/studio
   - Instalar con SDK por defecto
   - Abrir Android Studio → Tools → SDK Manager
   - Instalar Android SDK 33 (API 33)

4. **Configurar Android Studio**
   ```bash
   flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"
   ```

5. **Verificar instalación**
   ```bash
   flutter doctor
   ```

### macOS

```bash
# Instalar Flutter con Homebrew
brew install --cask flutter

# Instalar Xcode (desde App Store)
# Luego ejecutar:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Aceptar licencias
sudo xcodebuild -license accept

# Verificar
flutter doctor
```

### Linux (Ubuntu/Debian)

```bash
# Descargar Flutter
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz

# Agregar a PATH
echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Instalar dependencias
sudo apt update
sudo apt install curl git unzip xz-utils zip libglu1-mesa

# Verificar
flutter doctor
```

### Configurar Emulador Android

```bash
# Crear emulador
flutter emulators --create

# Listar emuladores
flutter emulators

# Iniciar emulador
flutter emulators --launch <emulator_id>
```

---

## 4. Configuración del Frontend

### Paso 1: Navegar al Directorio

```bash
cd app-movil
```

### Paso 2: Instalar Dependencias

```bash
flutter pub get
```

**Tiempo estimado:** 2-3 minutos

### Paso 3: Generar Código (Freezed)

**⚠️ MUY IMPORTANTE:** Este paso es obligatorio o la app no compilará.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Tiempo estimado:** 1-2 minutos

Esto generará ~30 archivos:
- `*.freezed.dart` - Modelos inmutables
- `*.g.dart` - Serialización JSON

### Paso 4: Configurar URL del Backend

Editar `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Para Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // Para iOS Simulator
  // static const String baseUrl = 'http://localhost:3000/api/v1';

  // Para dispositivo físico (reemplaza con tu IP local)
  // static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
}
```

**💡 Cómo obtener tu IP local:**

```bash
# Windows
ipconfig

# macOS/Linux
ifconfig

# Buscar dirección IPv4 (ej: 192.168.1.100)
```

---

## 5. Ejecución de la Aplicación

### Paso 1: Verificar Dispositivos

```bash
# Ver dispositivos disponibles
flutter devices
```

Deberías ver algo como:

```
Chrome (web) • chrome • web-javascript • Google Chrome 120.0.6099.199
Windows (desktop) • windows • windows-x64 • Microsoft Windows 11
sdk gphone64 arm64 (mobile) • emulator-5554 • android-x64 • Android 13 (API 33)
```

### Paso 2: Iniciar Backend (si no está corriendo)

```bash
# En otra terminal
cd backend
npm run start:dev
```

**Esperar a ver:**

```
✅ Database connection established
✅ Application is running on: http://localhost:3000
```

### Paso 3: Ejecutar Flutter App

```bash
cd app-movil

# Ejecutar en dispositivo específico
flutter run -d <device_id>

# O simplemente (Flutter te preguntará)
flutter run
```

**Opciones comunes:**

```bash
# Android Emulator
flutter run -d emulator-5554

# Chrome (web)
flutter run -d chrome

# Windows Desktop
flutter run -d windows
```

### Paso 4: Esperar Compilación

**Primera vez:** 3-5 minutos
**Subsecuentes:** 30-60 segundos

**✅ App corriendo exitosamente cuando veas:**

```
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
q Quit (terminate the application on the device).

An Observatory debugger and profiler on sdk gphone64 arm64 is available at: http://127.0.0.1:xxxxx/
The Flutter DevTools debugger and profiler on sdk gphone64 arm64 is available at: http://127.0.0.1:xxxxx/
```

---

## 6. Testing Completo

### 6.1. Test de Autenticación

1. **Pantalla de Login**
   - Abrir app → Debe mostrar pantalla de login
   - Ver tema azul telco

2. **Registro**
   ```
   Tap "Crear Cuenta"

   Llenar formulario:
   - Email: test@example.com
   - Password: Test123!
   - Confirmar Password: Test123!
   - Nombre: Juan
   - Apellido: Pérez
   - Teléfono: 1234567890
   - DNI: 12345678

   Tap "Registrarse"

   ✅ Debe redirigir al dashboard
   ```

3. **Login**
   ```
   Si ya cerraste sesión:

   Email: profesional1@reclamos.com
   Password: Password123!

   Tap "Iniciar Sesión"

   ✅ Debe mostrar dashboard con estadísticas
   ```

### 6.2. Test de Dashboard

En el dashboard deberías ver:

- ✅ Saludo personalizado ("¡Buenos días, [Nombre]!")
- ✅ 4 tarjetas de estadísticas:
  - Total Reclamos
  - Reclamos Abiertos
  - En Curso
  - Notificaciones No Leídas
- ✅ Botones de acciones rápidas
- ✅ Lista de reclamos recientes (máximo 3)
- ✅ Bottom navigation con 4 tabs

### 6.3. Test de Reclamos

1. **Crear Reclamo**
   ```
   Dashboard → Tap "Nuevo Reclamo"

   Llenar:
   - Título: "Internet sin conexión"
   - Descripción: "El servicio está intermitente desde ayer"
   - Categoría: INTERNET_FIBRA
   - Prioridad: ALTA

   Tap "Crear Reclamo"

   ✅ Debe aparecer en la lista
   ✅ Estado: ABIERTO (chip azul)
   ```

2. **Ver Lista**
   ```
   Bottom Nav → Tap "Reclamos"

   ✅ Ver lista de reclamos
   ✅ Probar filtros (tap ícono filtro)
   ✅ Pull to refresh
   ```

3. **Ver Detalle**
   ```
   Tap en un reclamo

   ✅ Ver 3 tabs: Info, Comentarios, Archivos
   ✅ Ver toda la información
   ✅ Tap en tab Comentarios
   ```

4. **Agregar Comentario**
   ```
   En detalle de reclamo → Tab "Comentarios"

   Escribir: "¿Cuándo podrán revisarlo?"
   Tap "Agregar"

   ✅ Comentario aparece en la lista
   ```

5. **Editar Reclamo**
   ```
   En detalle → Tap ícono editar (lápiz)

   Cambiar prioridad a: URGENTE
   Tap "Guardar"

   ✅ Cambios se reflejan
   ✅ Indicador de prioridad cambia a rojo
   ```

6. **Eliminar Reclamo**
   ```
   En detalle → Tap ícono eliminar (papelera)
   Confirmar en diálogo

   ✅ Reclamo eliminado
   ✅ Vuelve a lista
   ```

### 6.4. Test de Notificaciones

```
Bottom Nav → Tap "Notificaciones"

✅ Ver lista de notificaciones
✅ Ver contador de no leídas en badge
✅ Tap en notificación (marca como leída)
✅ Swipe para eliminar
✅ Tap "Marcar todas como leídas"
```

### 6.5. Test de Perfil

1. **Ver Perfil**
   ```
   Bottom Nav → Tap "Perfil"

   ✅ Ver información del usuario
   ✅ Ver rol
   ```

2. **Editar Perfil**
   ```
   Tap "Editar Perfil"

   Cambiar teléfono: 9876543210
   Tap "Guardar"

   ✅ Cambios guardados
   ✅ Vuelve a pantalla de perfil
   ```

3. **Cambiar Contraseña**
   ```
   Tap "Cambiar Contraseña"

   Llenar:
   - Contraseña actual: Password123!
   - Nueva contraseña: NewPass123!
   - Confirmar: NewPass123!

   Tap "Cambiar Contraseña"

   ✅ Contraseña cambiada
   ✅ Mensaje de éxito
   ```

4. **Logout**
   ```
   Tap "Cerrar Sesión"
   Confirmar en diálogo

   ✅ Redirige a login
   ✅ Sesión cerrada
   ```

### 6.6. Test de Navegación

```
✅ Probar cada tab del bottom navigation
✅ Usar botón back de Android
✅ Verificar que navegación es fluida
✅ No debería haber errores en consola
```

---

## 7. Solución de Problemas

### Error: "flutter: command not found"

**Solución:**

```bash
# Agregar Flutter a PATH
export PATH="$PATH:/ruta/a/flutter/bin"

# Verificar
flutter --version
```

### Error: "Unable to connect to backend"

**Solución:**

1. Verificar que backend esté corriendo:
   ```bash
   curl http://localhost:3000/api/v1/health
   ```

2. Si es emulador Android, usar `10.0.2.2` en lugar de `localhost`

3. Si es dispositivo físico, verificar que estén en la misma red WiFi

### Error: "build_runner not found"

**Solución:**

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "*.freezed.dart not found"

**Causa:** No ejecutaste build_runner

**Solución:**

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: Prisma migrations fail

**Solución:**

```bash
# Resetear base de datos
npm run prisma:reset

# Recrear
npm run prisma:migrate
npm run prisma:seed
```

### Error: Puerto 3000 en uso

**Windows:**

```bash
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

**macOS/Linux:**

```bash
lsof -ti:3000 | xargs kill -9
```

### App compila pero pantalla blanca

**Solución:**

1. Verificar URL del backend en `app_config.dart`
2. Ver logs en terminal:
   ```bash
   flutter logs
   ```
3. Hot restart:
   ```
   Presionar 'R' en terminal de Flutter
   ```

### Error: "Connection refused"

**Firewall Windows:**

```
1. Buscar "Firewall de Windows Defender"
2. Clic en "Permitir una aplicación..."
3. Agregar Node.js
4. Permitir en redes privadas y públicas
```

---

## 🎯 Checklist Final

Antes de dar por terminada la instalación, verifica:

- [ ] Backend corriendo en puerto 3000
- [ ] Swagger accesible en http://localhost:3000/api
- [ ] Flutter instalado (`flutter doctor` sin errores críticos)
- [ ] Dependencias del frontend instaladas (`flutter pub get`)
- [ ] Código generado (`build_runner`)
- [ ] App ejecutándose en emulador/dispositivo
- [ ] Login funciona
- [ ] Puedes crear un reclamo
- [ ] Puedes ver reclamos
- [ ] Puedes agregar comentarios
- [ ] Notificaciones funcionan
- [ ] Perfil se puede editar
- [ ] Logout funciona

---

## 📚 Recursos Adicionales

### Documentación

- **Backend:** `backend/README.md`
- **Frontend:** `app-movil/README.md`
- **Arquitectura:** `docs/ARCHITECTURE.md`
- **API Endpoints:** http://localhost:3000/api

### Comandos Útiles

```bash
# Backend
npm run start:dev       # Iniciar en desarrollo
npm run build           # Compilar para producción
npm run prisma:studio   # Abrir DB en navegador
npm run test            # Ejecutar tests

# Frontend
flutter run             # Ejecutar app
flutter run -d chrome   # Ejecutar en Chrome
flutter clean           # Limpiar caché
flutter analyze         # Analizar código
flutter test            # Ejecutar tests
```

### Atajos de Flutter

Mientras la app está corriendo:

- `r` - Hot reload (recarga cambios)
- `R` - Hot restart (reinicia app)
- `p` - Mostrar grid de píxeles
- `o` - Toggle iOS/Android
- `q` - Quit (cerrar app)

---

## 🆘 Soporte

Si encuentras problemas:

1. **Revisar logs:**
   - Backend: Salida en terminal donde corrió `npm run start:dev`
   - Frontend: Salida en terminal donde corrió `flutter run`

2. **Revisar documentación:**
   - Flutter: https://flutter.dev/docs
   - NestJS: https://docs.nestjs.com
   - Prisma: https://www.prisma.io/docs

3. **GitHub Issues:**
   - https://github.com/Rene-Kuhm/app-reclamos-telecomunicasiones/issues

---

**¡Feliz desarrollo!** 🚀

---

**Última actualización:** Noviembre 2025
**Versión:** 1.0.0
