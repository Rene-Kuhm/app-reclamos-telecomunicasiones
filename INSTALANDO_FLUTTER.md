# 🦋 Instalación Manual de Flutter en Windows

## ⚠️ Estado Actual

Los intentos automáticos de instalación han fallado debido a permisos del sistema.
**Solución: Instalación Manual** (15 minutos)

## 📥 Opción 1: Descarga Manual (RECOMENDADO)

### Paso 1: Descargar Flutter SDK

1. Abre tu navegador web
2. Ve a: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.1-stable.zip
3. Guarda el archivo en `C:\Users\insyd\Downloads\flutter.zip`
4. Espera a que termine la descarga (~1 GB, 5-10 minutos)

### Paso 2: Extraer Flutter

1. Abre el Explorador de Windows
2. Navega a `C:\Users\insyd\Downloads`
3. Haz clic derecho en `flutter.zip`
4. Selecciona "Extraer todo..."
5. Extrae a `C:\src\flutter` (crea la carpeta `C:\src` si no existe)

### Paso 3: Agregar Flutter al PATH

**Método 1: Variables de Entorno (GUI)**
1. Presiona `Win + R`, escribe `sysdm.cpl` y presiona Enter
2. Ve a la pestaña "Opciones avanzadas"
3. Haz clic en "Variables de entorno"
4. En "Variables del sistema", busca "Path"
5. Haz clic en "Editar"
6. Haz clic en "Nuevo"
7. Agrega: `C:\src\flutter\bin`
8. Haz clic en "Aceptar" en todas las ventanas

**Método 2: PowerShell (Administrador)**
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", "Machine")
```

### Paso 4: Verificar Instalación

Abre una **nueva** ventana de PowerShell o CMD y ejecuta:
```bash
flutter --version
flutter doctor
```

## 📥 Opción 2: Usar Scoop (Alternativa)

## 🎯 Después de la Instalación

Una vez Flutter esté instalado, podrás:

```bash
# 1. Ir al proyecto
cd "D:\aplicacion de reclamos telecomunicasiones rene\app-movil"

# 2. Instalar dependencias
flutter pub get

# 3. Generar código Freezed
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Ejecutar la app
flutter run
```

## 🖥️ Lo que Verás

### Pantalla de Login
```
┌─────────────────────────────┐
│   📱 RECLAMOS TELCO         │
│                             │
│   Email:                    │
│   ┌─────────────────────┐   │
│   │                     │   │
│   └─────────────────────┘   │
│                             │
│   Password:                 │
│   ┌─────────────────────┐   │
│   │ ••••••••            │   │
│   └─────────────────────┘   │
│                             │
│   [ INICIAR SESIÓN ]        │
│                             │
│   ¿No tienes cuenta?        │
│   Crear Cuenta              │
└─────────────────────────────┘
```

### Dashboard
```
┌─────────────────────────────┐
│ 🏠  Dashboard               │
├─────────────────────────────┤
│                             │
│ ¡Buenos días, Ana!          │
│                             │
│ ┌────┐  ┌────┐  ┌────┐     │
│ │ 12 │  │  3 │  │  2 │     │
│ │Tot │  │Abi │  │Cur │     │
│ └────┘  └────┘  └────┘     │
│                             │
│ ACCIONES RÁPIDAS            │
│ [ + Nuevo Reclamo ]         │
│ [ 📋 Ver Todos ]            │
│                             │
│ RECLAMOS RECIENTES          │
│ • Internet sin servicio     │
│ • Velocidad lenta           │
│ • Línea con interferencia   │
└─────────────────────────────┘
```

## 🔐 Usuarios para Probar

```
profesional1@reclamos.com
Password123!

tecnico1@reclamos.com
Password123!

admin@reclamos.com
Password123!
```

## ⚙️ Configuración del Backend

**IMPORTANTE:** El backend necesita PostgreSQL para funcionar correctamente.

### Opción A: Usar Supabase (Recomendado - 10 min)

1. Ir a https://supabase.com
2. Crear proyecto gratis
3. Copiar Connection String
4. Actualizar en `backend/.env`:
   ```env
   DATABASE_URL="postgresql://..."
   ```
5. Editar `backend/prisma/schema.prisma` línea 9:
   ```prisma
   provider = "postgresql"  # Cambiar de "sqlite"
   ```
6. Ejecutar:
   ```bash
   cd backend
   npx prisma migrate reset
   npm run prisma:seed
   npm run start:dev
   ```

### Opción B: Adaptar a SQLite (2-3 horas)

Requiere modificar ~30 archivos del backend para reemplazar enums.

## 📊 Progreso de Instalación

```
[████████████████░░░░░░░░░░] 60% - Descargando Flutter
[░░░░░░░░░░░░░░░░░░░░░░░░░░]  0% - Extrayendo archivos
[░░░░░░░░░░░░░░░░░░░░░░░░░░]  0% - Configurando PATH
[░░░░░░░░░░░░░░░░░░░░░░░░░░]  0% - Ejecutando flutter doctor
[░░░░░░░░░░░░░░░░░░░░░░░░░░]  0% - Generando código de app
[░░░░░░░░░░░░░░░░░░░░░░░░░░]  0% - Ejecutando aplicación
```

## 🎓 Comandos Útiles de Flutter

```bash
# Ver versión
flutter --version

# Verificar instalación
flutter doctor

# Ver dispositivos disponibles
flutter devices

# Limpiar caché
flutter clean

# Actualizar Flutter
flutter upgrade

# Ver ayuda
flutter help
```

## 📱 Dispositivos para Testing

Una vez Flutter esté instalado, puedes ejecutar en:

1. **Chrome** (Web) - Más rápido para testing
2. **Android Emulator** - Requiere Android Studio
3. **Windows Desktop** - App de escritorio
4. **Dispositivo físico** - Via USB

Recomendación: **Usar Chrome** para testing rápido.

## 🚀 Siguiente Paso

Espera a que termine la descarga (5-10 minutos).
El proceso continuará automáticamente.

---

**Tiempo estimado total:** 15-20 minutos
**Tamaño de descarga:** ~1 GB
**Espacio en disco:** ~2.5 GB después de extraer
