# Sistema de Gestión de Reclamos - Telecomunicaciones

Sistema enterprise-grade para gestión interna de reclamos de telecomunicaciones. Aplicación multiplataforma (Android, iOS, Web) con backend robusto y sistema de notificaciones multi-canal.

## Descripción

Sistema diseñado para empresas de telecomunicaciones que permite a profesionales crear y dar seguimiento a reclamos, mientras que técnicos pueden recibir asignaciones y resolverlos eficientemente. Incluye notificaciones en tiempo real vía Telegram, Email y Push Notifications.

### Tipos de Reclamos Soportados
- **Internet ADSL**: Problemas de conectividad, velocidad, configuración
- **Internet Fibra Óptica**: Cortes de servicio, baja velocidad, equipos
- **Teléfono Fijo ADSL**: Problemas de línea, calidad de audio
- **Teléfono Fijo Fibra**: Conectividad VoIP, equipos
- **TV por Cable (Sensa)**: Señal, canales, decodificadores

## Stack Tecnológico

### Frontend
- **Framework:** Flutter 3.24+
- **State Management:** Riverpod 2.5.0
- **Architecture:** Clean Architecture
- **Platforms:** Android, iOS, Web (PWA)

### Backend
- **Framework:** NestJS 10.3.0
- **Language:** TypeScript 5.3.3
- **Database:** PostgreSQL 15+ (Supabase)
- **ORM:** Prisma 5.8.0
- **Authentication:** JWT + Refresh Tokens + MFA

### Infrastructure
- **Database Hosting:** Supabase (500MB free)
- **Backend Hosting:** Railway ($5/month credit)
- **Frontend Hosting:** Firebase Hosting (10GB free)
- **Notifications:** Telegram Bot API, OneSignal, Gmail SMTP

## Características Principales

### Gestión de Reclamos
- ✅ CRUD completo de reclamos
- ✅ Workflow: Abierto → Asignado → En Curso → Revisión → Cerrado
- ✅ Prioridades: Baja, Media, Alta, Urgente
- ✅ Categorización por tipo de servicio
- ✅ Geolocalización de problemas
- ✅ Seguimiento de SLA
- ✅ Sistema de calificaciones

### Sistema de Usuarios
- ✅ 4 roles: Profesional, Técnico, Supervisor, Administrador
- ✅ RBAC (Control de acceso basado en roles)
- ✅ Autenticación segura con JWT
- ✅ MFA opcional (Google Authenticator)
- ✅ Gestión de sesiones
- ✅ Perfiles personalizables

### Notificaciones Multi-Canal
- ✅ **Telegram Bot**: Notificaciones instantáneas
- ✅ **Email**: Resúmenes y alertas importantes
- ✅ **Push Notifications**: Notificaciones móviles con OneSignal
- ✅ Cola de mensajes con reintentos
- ✅ Preferencias configurables por usuario

### Seguridad (OWASP Top 10)
- ✅ SQL Injection prevention (Prisma ORM)
- ✅ XSS prevention (sanitización de inputs)
- ✅ CSRF protection
- ✅ Rate limiting
- ✅ Helmet security headers
- ✅ Bcrypt password hashing (12 rounds)
- ✅ JWT con refresh tokens
- ✅ MFA opcional

### Auditoría y Trazabilidad
- ✅ Registro completo de cambios
- ✅ Historial de estados
- ✅ Sistema de comentarios
- ✅ Carga de archivos adjuntos
- ✅ Logging estructurado con Winston
- ✅ Monitoreo de errores con Sentry

## Estructura del Proyecto

```
.
├── backend/                    # Backend NestJS + Prisma
│   ├── src/
│   │   ├── modules/           # Módulos de funcionalidad
│   │   ├── common/            # Utilidades compartidas
│   │   └── config/            # Configuración
│   ├── prisma/                # Schema y migraciones
│   └── test/                  # Tests unitarios e integración
│
├── app-movil/                 # Aplicación Flutter
│   ├── lib/
│   │   ├── core/             # Configuración y utilidades
│   │   ├── features/         # Features (auth, reclamos, etc.)
│   │   └── shared/           # Componentes compartidos
│   └── test/                 # Tests de Flutter
│
├── infrastructure/            # Docker, Kubernetes, Terraform
│   └── docker/               # Dockerfiles
│
├── docs/                     # Documentación
│   └── ARCHITECTURE.md       # Arquitectura detallada
│
└── scripts/                  # Scripts de utilidad
```

## Quick Start

### Requisitos Previos
- Node.js 20 LTS
- Flutter 3.24+
- PostgreSQL 15+ (o cuenta de Supabase)
- Git

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd "aplicacion de reclamos telecomunicasiones rene"
```

### 2. Configurar Backend

```bash
cd backend

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# Generar cliente Prisma
npm run prisma:generate

# Ejecutar migraciones
npm run prisma:migrate

# Iniciar servidor de desarrollo
npm run start:dev
```

El backend estará disponible en `http://localhost:3000`

### 3. Configurar App Móvil

```bash
cd app-movil

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run
```

## Configuración de Servicios Externos

### Supabase (Database)
1. Crear cuenta en https://supabase.com
2. Crear nuevo proyecto
3. Copiar `DATABASE_URL` desde Settings → Database
4. Actualizar `.env` en backend

### Telegram Bot
1. Hablar con @BotFather en Telegram
2. Crear nuevo bot con `/newbot`
3. Copiar token del bot
4. Actualizar `TELEGRAM_BOT_TOKEN` en `.env`

### Gmail SMTP
1. Habilitar verificación en 2 pasos en tu cuenta Google
2. Generar contraseña de aplicación: https://myaccount.google.com/apppasswords
3. Actualizar `SMTP_USER` y `SMTP_PASSWORD` en `.env`

### OneSignal (Push Notifications)
1. Crear cuenta en https://onesignal.com
2. Crear nueva app
3. Copiar App ID y API Key
4. Actualizar `ONESIGNAL_APP_ID` y `ONESIGNAL_API_KEY`

### Railway (Backend Hosting)
1. Crear cuenta en https://railway.app
2. Conectar repositorio GitHub
3. Configurar variables de entorno
4. Deploy automático

## Scripts Disponibles

### Backend
```bash
npm run start:dev      # Desarrollo con hot-reload
npm run build          # Build para producción
npm run test           # Ejecutar tests
npm run test:cov       # Tests con coverage
npm run prisma:studio  # Abrir Prisma Studio
```

### Frontend
```bash
flutter run            # Ejecutar en desarrollo
flutter build apk      # Build APK Android
flutter build ios      # Build iOS
flutter build web      # Build Web
flutter test           # Ejecutar tests
```

## Testing

### Backend
```bash
cd backend
npm run test           # Tests unitarios
npm run test:e2e       # Tests E2E
npm run test:cov       # Coverage (objetivo: >80%)
```

### Frontend
```bash
cd app-movil
flutter test           # Tests unitarios y widgets
```

## Deployment

### Backend (Railway)
1. Push código a GitHub
2. Railway detecta cambios automáticamente
3. Ejecuta build y deploy
4. Verifica en logs de Railway

### Frontend (Firebase Hosting)
```bash
cd app-movil
flutter build web
firebase deploy --only hosting
```

## Documentación

- [Arquitectura del Sistema](./docs/ARCHITECTURE.md)
- [Backend README](./backend/README.md)
- [API Documentation](http://localhost:3000/api) (Swagger)
- [Database Schema](./backend/prisma/schema.prisma)

## Roles y Permisos

| Rol | Permisos |
|-----|----------|
| **Profesional** | Crear reclamos, ver sus propios reclamos, agregar comentarios, calificar resoluciones |
| **Técnico** | Ver reclamos asignados, actualizar estado, agregar comentarios, resolver reclamos, subir archivos |
| **Supervisor** | Todo lo de Técnico + asignar reclamos manualmente, ver todos los reclamos, aprobar cierres |
| **Administrador** | Acceso completo, gestionar usuarios, configuración del sistema, estadísticas globales |

## Workflow de Reclamos

```
1. ABIERTO → Profesional crea reclamo
2. ASIGNADO → Sistema asigna técnico (o supervisor lo hace manualmente)
3. EN_CURSO → Técnico trabaja en la solución
4. EN_REVISION → Esperando aprobación del supervisor (opcional)
5. CERRADO → Reclamo resuelto exitosamente
   O RECHAZADO → Reclamo cancelado/rechazado
```

## Seguridad

- Todas las passwords hasheadas con Bcrypt (12 rounds)
- JWT tokens con expiración corta (15 min)
- Refresh tokens revocables
- Rate limiting en todas las rutas
- Validación y sanitización de inputs
- Auditoría completa de acciones
- HTTPS obligatorio en producción

## Monitoreo

- **Logs**: Winston con rotación diaria
- **Errors**: Sentry para tracking de errores
- **Health checks**: `/health`, `/health/ready`, `/health/live`
- **Metrics**: Prometheus endpoint en `/metrics`

## Estimación de Costos

Para <50 usuarios:
- Database (Supabase): **$0** (free tier)
- Backend (Railway): **$0-2/mes** (sleep after inactivity)
- Frontend (Firebase): **$0** (free tier)
- Telegram: **$0** (gratis ilimitado)
- OneSignal: **$0** (< 10k subscribers)
- Gmail SMTP: **$0** (< 500 emails/día)

**Total estimado: $0-2/mes** 🎉

## Troubleshooting

### Backend no inicia
- Verificar `DATABASE_URL` en `.env`
- Ejecutar `npm run prisma:generate`
- Verificar que PostgreSQL esté corriendo

### Flutter no compila
- Ejecutar `flutter clean`
- Ejecutar `flutter pub get`
- Verificar versión de Flutter: `flutter doctor`

### Notificaciones no llegan
- Verificar tokens en `.env`
- Revisar logs de backend
- Verificar conectividad a servicios externos

## Soporte y Contribución

Para reportar bugs o solicitar features, crear un issue en el repositorio.

## Licencia

Propietario - Uso interno únicamente

---

**Desarrollado con:** ❤️ + ☕ + 🚀

**Stack:** Flutter + NestJS + PostgreSQL + Supabase + Railway
