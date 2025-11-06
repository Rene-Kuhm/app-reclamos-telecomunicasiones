# Arquitectura del Sistema - Gestión de Reclamos Telco

## 1. Visión General

Sistema enterprise-grade de gestión de reclamos internos para empresa de telecomunicaciones, diseñado para profesionales y técnicos. Maneja reclamos de:
- Internet ADSL y Fibra Óptica
- Teléfono Fijo (ADSL/Fibra)
- TV por Cable (Sensa)

### Características Principales
- Aplicación multiplataforma (Android, iOS, Web) con Flutter
- Backend robusto con NestJS y PostgreSQL
- Sistema de notificaciones multi-canal (Telegram, Email, Push)
- Workflow completo de reclamos con asignación automática
- RBAC con 4 roles: Profesional, Técnico, Supervisor, Administrador
- Seguridad enterprise (OWASP Top 10, MFA, JWT)
- Optimizado para free tiers (~$0-2/mes)

---

## 2. Stack Tecnológico

### Frontend
```yaml
Platform: Flutter 3.24+
Language: Dart 3.5+
State Management: Riverpod 2.5.0
Architecture: Clean Architecture + Feature-based
Platforms: Android, iOS, Web (PWA)

Key Libraries:
  - dio: 5.4.0                    # HTTP client
  - retrofit: 4.1.0               # Type-safe API
  - riverpod: 2.5.0               # State management
  - go_router: 14.0.0             # Navigation
  - hive: 2.2.3                   # Local storage
  - flutter_secure_storage: 9.0.0 # Secure tokens
  - onesignal_flutter: 5.1.0      # Push notifications
  - cached_network_image: 3.3.0   # Image caching
  - flutter_screenutil: 5.9.0     # Responsive design
```

### Backend
```json
{
  "platform": "Node.js 20 LTS",
  "framework": "NestJS 10.3.0",
  "language": "TypeScript 5.3.0",
  "database": "PostgreSQL 15+",
  "orm": "Prisma 5.8.0",

  "core_dependencies": {
    "@nestjs/core": "10.3.0",
    "@nestjs/common": "10.3.0",
    "@nestjs/jwt": "10.2.0",
    "@nestjs/passport": "10.0.3",
    "@nestjs/swagger": "7.2.0",
    "@nestjs/terminus": "10.2.0",
    "@prisma/client": "5.8.0"
  },

  "security": {
    "bcrypt": "5.1.1",
    "helmet": "7.1.0",
    "@nestjs/throttler": "5.1.0",
    "class-validator": "0.14.1"
  },

  "monitoring": {
    "winston": "3.11.0",
    "@sentry/node": "7.99.0"
  },

  "notifications": {
    "node-telegram-bot-api": "0.64.0",
    "nodemailer": "6.9.8",
    "onesignal-node": "3.4.0"
  }
}
```

### Infrastructure
```yaml
Database: Supabase PostgreSQL (500MB free)
Backend Hosting: Railway ($5 credit/month)
Frontend Hosting: Firebase Hosting (10GB free)
File Storage: Supabase Storage (1GB free)
Cache/Queue: Upstash Redis (10k commands/day free)
Monitoring: Sentry (5k errors/month free)
```

---

## 3. Arquitectura de Alto Nivel

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENTS (Flutter)                       │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                │
│  │ Android  │  │   iOS    │  │    Web   │                │
│  │   App    │  │   App    │  │   PWA    │                │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                │
│       │             │             │                        │
│       └─────────────┴─────────────┘                        │
│                     │                                      │
└─────────────────────┼──────────────────────────────────────┘
                      │
                      │ HTTPS/WSS
                      │
┌─────────────────────▼──────────────────────────────────────┐
│                  API GATEWAY / NGINX                        │
│                  (Rate Limiting, CORS)                      │
└─────────────────────┬──────────────────────────────────────┘
                      │
┌─────────────────────▼──────────────────────────────────────┐
│              BACKEND (NestJS on Railway)                    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Authentication Module                    │  │
│  │  (JWT, Refresh Tokens, MFA, Passport Strategies)    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────┐  ┌───────────┐  ┌──────────────┐          │
│  │ Usuarios  │  │ Reclamos  │  │Notificaciones│          │
│  │  Module   │  │  Module   │  │   Module     │          │
│  └─────┬─────┘  └─────┬─────┘  └──────┬───────┘          │
│        │              │                │                   │
│  ┌─────▼──────────────▼────────────────▼─────────┐        │
│  │         Prisma ORM (Data Access Layer)        │        │
│  └────────────────────┬──────────────────────────┘        │
└───────────────────────┼────────────────────────────────────┘
                        │
                        │
┌───────────────────────▼────────────────────────────────────┐
│              SUPABASE PostgreSQL 15                         │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ usuarios │  │ reclamos │  │notificac.│  │archivos  │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              EXTERNAL SERVICES                              │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Telegram │  │  Gmail   │  │OneSignal │  │  Sentry  │  │
│  │   Bot    │  │   SMTP   │  │   Push   │  │  Error   │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Arquitectura de Backend (NestJS)

### 4.1 Clean Architecture en Capas

```
backend_node/
└── src/
    ├── main.ts                      # Entry point
    ├── app.module.ts                # Root module
    │
    ├── common/                      # Shared utilities
    │   ├── decorators/              # Custom decorators
    │   ├── filters/                 # Exception filters
    │   ├── guards/                  # Auth & RBAC guards
    │   ├── interceptors/            # Logging, transform
    │   ├── pipes/                   # Validation pipes
    │   └── utils/                   # Helpers
    │
    ├── config/                      # Configuration
    │   ├── configuration.ts         # Env variables
    │   ├── database.config.ts
    │   └── jwt.config.ts
    │
    └── modules/                     # Feature modules
        │
        ├── auth/                    # Authentication
        │   ├── auth.controller.ts
        │   ├── auth.service.ts
        │   ├── auth.module.ts
        │   ├── dto/
        │   ├── strategies/          # JWT, Refresh strategies
        │   └── guards/
        │
        ├── usuarios/                # User management
        │   ├── usuarios.controller.ts
        │   ├── usuarios.service.ts
        │   ├── usuarios.module.ts
        │   └── dto/
        │
        ├── reclamos/                # Claims management
        │   ├── reclamos.controller.ts
        │   ├── reclamos.service.ts
        │   ├── reclamos.module.ts
        │   ├── dto/
        │   ├── services/
        │   │   ├── asignacion.service.ts
        │   │   └── workflow.service.ts
        │   └── entities/
        │
        └── notificaciones/          # Notifications
            ├── notificaciones.service.ts
            ├── notificaciones.module.ts
            ├── providers/
            │   ├── telegram.provider.ts
            │   ├── email.provider.ts
            │   └── onesignal.provider.ts
            ├── queue/
            │   └── notificaciones.processor.ts
            └── templates/
```

### 4.2 Módulos Principales

#### Auth Module
- Registro y login con email/password
- JWT access tokens (15min) + refresh tokens (7 días)
- MFA con TOTP (Google Authenticator)
- Verificación de email
- Reset de contraseña
- Estrategias Passport (JWT, Refresh)

#### Usuarios Module
- CRUD completo de usuarios
- Gestión de roles y permisos
- Perfil de usuario con avatar
- Sesiones activas
- Historial de actividad

#### Reclamos Module
- CRUD completo de reclamos
- Workflow: Abierto → Asignado → En Curso → En Revisión → Cerrado/Rechazado
- Asignación automática de técnicos (por categoría, carga de trabajo, disponibilidad)
- Categorías específicas: Internet ADSL, Fibra Óptica, Teléfono Fijo, TV Sensa
- Sistema de prioridades: Baja, Media, Alta, Urgente
- SLA tracking y alertas
- Comentarios y auditoría completa
- Carga de archivos adjuntos

#### Notificaciones Module
- Multi-canal: Telegram, Email, Push
- Cola de mensajes con Bull + Redis
- Reintentos con backoff exponencial
- Plantillas personalizables
- Preferencias por usuario
- Tracking de entrega y lectura

---

## 5. Arquitectura de Frontend (Flutter)

### 5.1 Clean Architecture + Feature-based

```
frontend_flutter/
└── lib/
    ├── main.dart                    # Entry point
    │
    ├── core/                        # Core functionality
    │   ├── config/
    │   │   ├── app_config.dart      # Environment config
    │   │   └── api_config.dart      # API endpoints
    │   │
    │   ├── constants/
    │   │   ├── app_constants.dart
    │   │   └── enums.dart
    │   │
    │   ├── di/
    │   │   └── injection.dart       # Riverpod providers
    │   │
    │   ├── errors/
    │   │   ├── exceptions.dart
    │   │   └── failures.dart
    │   │
    │   ├── network/
    │   │   ├── dio_client.dart      # HTTP client config
    │   │   ├── api_interceptor.dart # Auth, logging
    │   │   └── network_info.dart
    │   │
    │   ├── router/
    │   │   └── app_router.dart      # Go Router config
    │   │
    │   ├── theme/
    │   │   ├── app_theme.dart       # Light/Dark themes
    │   │   ├── app_colors.dart
    │   │   └── app_text_styles.dart
    │   │
    │   └── utils/
    │       ├── validators.dart
    │       ├── extensions.dart
    │       └── helpers.dart
    │
    ├── features/                    # Feature modules
    │   │
    │   ├── auth/
    │   │   ├── data/
    │   │   │   ├── datasources/
    │   │   │   │   ├── auth_remote_datasource.dart
    │   │   │   │   └── auth_local_datasource.dart
    │   │   │   ├── models/
    │   │   │   │   └── user_model.dart
    │   │   │   └── repositories/
    │   │   │       └── auth_repository_impl.dart
    │   │   │
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   │   └── user.dart
    │   │   │   ├── repositories/
    │   │   │   │   └── auth_repository.dart
    │   │   │   └── usecases/
    │   │   │       ├── login_usecase.dart
    │   │   │       ├── register_usecase.dart
    │   │   │       └── logout_usecase.dart
    │   │   │
    │   │   └── presentation/
    │   │       ├── providers/
    │   │       │   └── auth_provider.dart
    │   │       ├── screens/
    │   │       │   ├── login_screen.dart
    │   │       │   ├── register_screen.dart
    │   │       │   └── forgot_password_screen.dart
    │   │       └── widgets/
    │   │           ├── login_form.dart
    │   │           └── password_field.dart
    │   │
    │   ├── reclamos/
    │   │   ├── data/
    │   │   │   ├── datasources/
    │   │   │   ├── models/
    │   │   │   └── repositories/
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   │   └── reclamo.dart
    │   │   │   ├── repositories/
    │   │   │   └── usecases/
    │   │   │       ├── crear_reclamo_usecase.dart
    │   │   │       ├── obtener_reclamos_usecase.dart
    │   │   │       └── actualizar_estado_usecase.dart
    │   │   └── presentation/
    │   │       ├── providers/
    │   │       ├── screens/
    │   │       │   ├── reclamos_list_screen.dart
    │   │       │   ├── reclamo_detail_screen.dart
    │   │       │   └── crear_reclamo_screen.dart
    │   │       └── widgets/
    │   │           ├── reclamo_card.dart
    │   │           ├── estado_badge.dart
    │   │           └── prioridad_indicator.dart
    │   │
    │   ├── notificaciones/
    │   └── perfil/
    │
    └── shared/                      # Shared components
        ├── widgets/
        │   ├── custom_button.dart
        │   ├── custom_text_field.dart
        │   ├── loading_indicator.dart
        │   └── error_widget.dart
        ├── models/
        └── services/
```

### 5.2 State Management con Riverpod

```dart
// Ejemplo de provider structure

// 1. Repository Provider
final reclamoRepositoryProvider = Provider<ReclamoRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReclamoRepositoryImpl(remoteDataSource: ReclamoRemoteDataSourceImpl(dio));
});

// 2. UseCase Provider
final obtenerReclamosUseCaseProvider = Provider<ObtenerReclamosUseCase>((ref) {
  final repository = ref.watch(reclamoRepositoryProvider);
  return ObtenerReclamosUseCase(repository);
});

// 3. State Notifier Provider
final reclamosProvider = StateNotifierProvider<ReclamosNotifier, AsyncValue<List<Reclamo>>>((ref) {
  final useCase = ref.watch(obtenerReclamosUseCaseProvider);
  return ReclamosNotifier(useCase);
});

// 4. UI consumes provider
class ReclamosListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reclamosState = ref.watch(reclamosProvider);

    return reclamosState.when(
      data: (reclamos) => ListView.builder(...),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

## 6. Modelo de Datos (Database Schema)

### 6.1 Entidades Principales

```prisma
// Usuario
model Usuario {
  id                    String        @id @default(uuid())
  email                 String        @unique
  password_hash         String
  nombre                String
  apellido              String
  telefono              String?
  avatar_url            String?

  rol                   RolUsuario    // PROFESIONAL, TECNICO, SUPERVISOR, ADMIN
  activo                Boolean       @default(true)
  email_verificado      Boolean       @default(false)

  // MFA
  mfa_habilitado        Boolean       @default(false)
  mfa_secret            String?

  // Notificaciones
  telegram_chat_id      String?
  onesignal_player_id   String?
  preferencias_notif    Json?

  // Relaciones
  reclamos_creados      Reclamo[]     @relation("ReclamosProfesional")
  reclamos_asignados    Reclamo[]     @relation("ReclamosTecnico")
  notificaciones        Notificacion[]

  created_at            DateTime      @default(now())
  updated_at            DateTime      @updatedAt
  deleted_at            DateTime?
}

// Reclamo
model Reclamo {
  id                      String           @id @default(uuid())
  numero_reclamo          String           @unique  // RCL-2024-00001

  titulo                  String
  descripcion             String

  estado                  EstadoReclamo    @default(ABIERTO)
  prioridad               PrioridadReclamo @default(MEDIA)

  // Categorías específicas de Telco
  categoria               CategoriaReclamo // INTERNET_ADSL, INTERNET_FIBRA, TELEFONO_ADSL, TELEFONO_FIBRA, TV_SENSA
  subcategoria            String?

  // Ubicación
  direccion               String?
  latitud                 Decimal?
  longitud                Decimal?

  // Relaciones
  id_profesional          String
  profesional             Usuario          @relation("ReclamosProfesional")

  id_tecnico_asignado     String?
  tecnico_asignado        Usuario?         @relation("ReclamosTecnico")

  // Fechas
  fecha_creacion          DateTime         @default(now())
  fecha_asignacion        DateTime?
  fecha_inicio_trabajo    DateTime?
  fecha_resolucion        DateTime?
  fecha_cierre            DateTime?

  // SLA
  sla_respuesta_horas     Int              @default(24)
  sla_resolucion_horas    Int              @default(72)
  sla_vencimiento         DateTime?
  sla_cumplido            Boolean?

  // Resolución
  notas_resolucion        String?
  calificacion            Int?             // 1-5 estrellas

  // Relaciones
  notificaciones          Notificacion[]
  auditorias              AuditoriaReclamo[]
  comentarios             Comentario[]
  archivos                Archivo[]

  created_at              DateTime         @default(now())
  updated_at              DateTime         @updatedAt
  deleted_at              DateTime?
}

// Enums
enum RolUsuario {
  PROFESIONAL
  TECNICO
  SUPERVISOR
  ADMINISTRADOR
}

enum EstadoReclamo {
  ABIERTO
  ASIGNADO
  EN_CURSO
  EN_REVISION
  CERRADO
  RECHAZADO
}

enum PrioridadReclamo {
  BAJA
  MEDIA
  ALTA
  URGENTE
}

enum CategoriaReclamo {
  INTERNET_ADSL
  INTERNET_FIBRA
  TELEFONO_ADSL
  TELEFONO_FIBRA
  TV_SENSA
}
```

### 6.2 Diagrama ER

```
┌──────────────┐         ┌──────────────┐
│   Usuario    │◄───────┐│   Reclamo    │
│              │        ││              │
│ - id         │        ││ - id         │
│ - email      │        ││ - numero     │
│ - nombre     │        ││ - titulo     │
│ - rol        │        ││ - estado     │
│ - activo     │        ││ - prioridad  │
└──────┬───────┘        ││ - categoria  │
       │                │└──────┬───────┘
       │                │       │
       │ crea           │       │ tiene
       │                │       │
       │        asignado│       │
       └────────────────┘       │
                                │
                    ┌───────────┼───────────┐
                    │           │           │
                    │           │           │
         ┌──────────▼─┐  ┌──────▼────┐  ┌──▼────────┐
         │Comentario  │  │Archivo    │  │Auditoria  │
         └────────────┘  └───────────┘  └───────────┘
```

---

## 7. Flujo de Trabajo de Reclamos

```
┌─────────┐
│ ABIERTO │  → Profesional crea reclamo
└────┬────┘
     │
     │ Sistema asigna técnico automáticamente
     │ (o supervisor asigna manualmente)
     │
┌────▼────┐
│ASIGNADO │  → Técnico recibe notificación
└────┬────┘
     │
     │ Técnico acepta y comienza trabajo
     │
┌────▼────┐
│EN_CURSO │  → Técnico trabaja en solución
└────┬────┘      (puede agregar comentarios y fotos)
     │
     │ Técnico marca como resuelto
     │
┌────▼──────┐
│EN_REVISION│  → Supervisor revisa (opcional)
└────┬──────┘
     │
     │ Supervisor/Sistema aprueba
     │
┌────▼───┐
│CERRADO │  → Profesional puede calificar
└────────┘

     │ O puede rechazar
     │
┌────▼─────┐
│RECHAZADO │  → Puede ser reabierto
└──────────┘
```

### Estados y Transiciones Permitidas

| Estado Actual  | Estados Siguientes Posibles | Quién puede cambiar |
|---------------|----------------------------|---------------------|
| ABIERTO       | ASIGNADO, RECHAZADO        | Supervisor, Sistema |
| ASIGNADO      | EN_CURSO, ABIERTO          | Técnico, Supervisor |
| EN_CURSO      | EN_REVISION, CERRADO       | Técnico             |
| EN_REVISION   | CERRADO, EN_CURSO          | Supervisor          |
| CERRADO       | -                          | -                   |
| RECHAZADO     | ABIERTO                    | Supervisor          |

---

## 8. Sistema de Notificaciones

### 8.1 Canales de Notificación

```
┌─────────────────────────────────────────────────────────┐
│              EVENTO DE RECLAMO                          │
│  (creado, asignado, cambio de estado, comentario)      │
└────────────────────┬────────────────────────────────────┘
                     │
                     │
         ┌───────────▼───────────┐
         │ NotificacionesService │
         └───────────┬───────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
┌───────▼───┐ ┌──────▼─────┐ ┌───▼──────┐
│ Telegram  │ │   Email    │ │  Push    │
│  Provider │ │  Provider  │ │ Provider │
└───────────┘ └────────────┘ └──────────┘
     │              │              │
     │              │              │
┌────▼────┐  ┌──────▼──────┐ ┌────▼──────┐
│Telegram │  │ Gmail SMTP  │ │ OneSignal │
│Bot API  │  │             │ │           │
└─────────┘  └─────────────┘ └───────────┘
```

### 8.2 Tipos de Notificaciones

| Evento | Destinatario | Canales | Prioridad |
|--------|-------------|---------|-----------|
| Nuevo reclamo | Técnicos disponibles | Telegram, Push | Alta |
| Reclamo asignado | Técnico asignado | Telegram, Email, Push | Alta |
| Cambio de estado | Profesional + Técnico | Email, Push | Media |
| Nuevo comentario | Participantes | Push | Baja |
| SLA próximo a vencer | Técnico + Supervisor | Telegram, Email | Urgente |
| Reclamo cerrado | Profesional | Email, Push | Baja |

### 8.3 Queue con Reintentos

```typescript
// Configuración de cola con Bull
await queue.add('enviar',
  { notificacionId: notif.id },
  {
    attempts: 3,              // 3 intentos
    backoff: {
      type: 'exponential',
      delay: 5000,            // 5s, 25s, 125s
    },
    priority: prioridad === 'URGENTE' ? 1 : 10,
  }
);
```

---

## 9. Seguridad (OWASP Top 10)

### 9.1 Autenticación y Autorización

```typescript
// JWT Strategy
- Access Token: 15 minutos (HS256)
- Refresh Token: 7 días (almacenado en DB con revocación)
- MFA opcional con TOTP (Google Authenticator)
- Verificación de email obligatoria
- Bloqueo de cuenta después de 5 intentos fallidos (30min)

// RBAC Guards
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(RolUsuario.ADMIN, RolUsuario.SUPERVISOR)
async obtenerEstadisticas() { ... }

// Resource-based Guards
@UseGuards(ReclamoOwnerGuard)  // Solo puede ver sus propios reclamos
async obtenerReclamo(@Param('id') id: string) { ... }
```

### 9.2 Prevención de Vulnerabilidades

| Vulnerabilidad | Contramedida | Implementación |
|---------------|-------------|----------------|
| A01: Broken Access Control | RBAC + Resource Guards | Guards personalizados en NestJS |
| A02: Cryptographic Failures | Bcrypt (12 rounds) | `bcrypt.hash(password, 12)` |
| A03: Injection | Prisma ORM | Queries parametrizadas automáticas |
| A03: XSS | Sanitización HTML | `sanitize-html` en inputs |
| A04: Insecure Design | Rate Limiting | Throttler: 10 req/min general |
| A05: Security Misconfiguration | Helmet + CORS | Headers de seguridad |
| A07: Auth Failures | JWT + MFA | Tokens cortos + TOTP |
| A09: Logging Failures | Winston + Sentry | Logs estructurados + alertas |

### 9.3 Rate Limiting

```typescript
// Global
ThrottlerModule.forRoot({
  ttl: 60,      // 60 segundos
  limit: 10,    // 10 requests
})

// Específico por endpoint
@Throttle(3, 60)  // 3 intentos de login por minuto
@Post('login')
async login() { ... }
```

---

## 10. Optimización para Free Tiers

### 10.1 Estrategia de Costos

```yaml
Objetivo: $0-2/mes para <50 usuarios

Database (Supabase):
  Storage: 500MB (gratis)
  Bandwidth: 2GB/mes (gratis)
  Optimización:
    - Índices en columnas frecuentes
    - Soft deletes para reducir espacio
    - Limpieza de logs antiguos (>90 días)
    - Compresión de archivos adjuntos

Backend (Railway):
  Credit: $5/mes (gratis)
  Usage: ~$2-3/mes con optimizaciones
  Optimización:
    - Sleep después de 30min inactividad
    - Minimizar dependencias
    - Lazy loading de módulos pesados
    - Cache con Redis (queries frecuentes)

Frontend (Firebase Hosting):
  Storage: 10GB (gratis)
  Bandwidth: 360MB/día (gratis)
  Optimización:
    - Code splitting por rutas
    - Lazy loading de widgets
    - Compresión de assets
    - CDN incluido

Notificaciones:
  Telegram: GRATIS ilimitado
  OneSignal: 10,000 subscribers (gratis)
  Gmail SMTP: 500 emails/día (gratis)
  Optimización:
    - Priorizar Telegram sobre Email
    - Agrupar notificaciones (digest diario)

Storage (Supabase):
  Storage: 1GB (gratis)
  Optimización:
    - Compresión de imágenes (JPEG 80%)
    - Límite de 5MB por archivo
    - Limpieza de archivos huérfanos
```

### 10.2 Monitoreo de Uso

```typescript
// Dashboard de métricas
- DB size: 500MB limit → alertar en 80%
- Backend requests: $5 credit → alertar en $4
- Email count: 500/día → alertar en 400
- Storage: 1GB → alertar en 800MB
```

---

## 11. CI/CD Pipeline

```yaml
# .github/workflows/backend-ci.yml

on: [push, pull_request]

jobs:
  test:
    - Lint (ESLint)
    - Type check (TypeScript)
    - Unit tests (Jest)
    - Integration tests
    - E2E tests
    - Coverage report (>80%)

  security:
    - npm audit (high severity)
    - Snyk scan
    - Dependabot

  build:
    - Docker build
    - Push to registry

  deploy:
    - Deploy to Railway (main branch)
    - Run migrations
    - Health check
```

---

## 12. Monitoreo y Observability

```
┌─────────────────────────────────────────────────────────┐
│                     APPLICATION                         │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
┌───────▼───┐ ┌──────▼─────┐ ┌───▼──────┐
│  Logging  │ │   Errors   │ │ Metrics  │
│  Winston  │ │   Sentry   │ │Prometheus│
└───────────┘ └────────────┘ └──────────┘
     │              │              │
     │              │              │
┌────▼────┐  ┌──────▼──────┐ ┌────▼──────┐
│  Files  │  │   Sentry    │ │  Grafana  │
│ /logs/  │  │  Dashboard  │ │ Dashboard │
└─────────┘  └─────────────┘ └───────────┘
```

### Health Checks

```
GET /health        → 200 OK (basic)
GET /health/ready  → 200 OK (DB + Redis conectados)
GET /health/live   → 200 OK (proceso vivo)
GET /metrics       → Prometheus metrics
```

---

## 13. Roadmap de Implementación

### Fase 1: Fundamentos (Semana 1-2)
- ✅ Estructura del proyecto
- ✅ Configuración de Supabase
- ✅ Setup de Railway
- ✅ Schema de Prisma
- ✅ Auth module (JWT + Refresh)

### Fase 2: Core Features (Semana 3-4)
- ✅ Módulo de usuarios
- ✅ Módulo de reclamos (CRUD)
- ✅ Sistema de workflow
- ✅ Asignación automática

### Fase 3: Notificaciones (Semana 5)
- ✅ Telegram Bot
- ✅ Email con Gmail
- ✅ Push con OneSignal
- ✅ Cola de mensajes

### Fase 4: Frontend (Semana 6-8)
- ✅ Setup Flutter + Riverpod
- ✅ Auth UI
- ✅ Reclamos UI
- ✅ Notificaciones UI
- ✅ Responsive design

### Fase 5: Testing & Deploy (Semana 9-10)
- ✅ Tests backend (>80%)
- ✅ Tests Flutter
- ✅ CI/CD pipeline
- ✅ Deploy a producción
- ✅ Documentación

---

## 14. Decisiones Técnicas Clave

### ¿Por qué Supabase?
- 500MB storage gratis (más que Railway/Render)
- UI de administración excelente
- Auth y Storage incluidos
- PostgreSQL completo (no limitado)
- APIs automáticas (opcional)

### ¿Por qué Railway para Backend?
- $5 crédito mensual gratis
- Deploy automático desde Git
- Fácil setup (más simple que Cloud Run)
- Sleep automático (ahorra recursos)
- Buena integración con PostgreSQL

### ¿Por qué Riverpod sobre BLoC?
- Type-safe en compile-time
- Menos boilerplate
- Mejor para proyectos medianos
- Excelente para testing
- Comunidad activa

### ¿Por qué Telegram como canal principal?
- GRATIS e ilimitado
- API muy simple
- Push instantáneo
- No requiere app adicional
- Soporta rich media

---

## 15. Escalabilidad Futura

### Si crece a 200+ usuarios:
```yaml
Database:
  - Migrar a Neon (10GB free) o plan pago de Supabase
  - Implementar read replicas
  - Particionar tabla de auditoría

Backend:
  - Aumentar instancias en Railway
  - Implementar cache agresivo (Redis)
  - Considerar microservicios

Frontend:
  - CDN premium (Cloudflare)
  - Service Workers para offline
  - Optimización de assets

Monitoring:
  - Grafana Cloud (métricas detalladas)
  - New Relic APM
  - Escalamiento de Sentry
```

---

## 16. Contactos y Referencias

### Documentación Oficial
- NestJS: https://docs.nestjs.com
- Flutter: https://docs.flutter.dev
- Prisma: https://www.prisma.io/docs
- Riverpod: https://riverpod.dev
- Supabase: https://supabase.com/docs
- Railway: https://docs.railway.app

### APIs Externas
- Telegram Bot API: https://core.telegram.org/bots/api
- OneSignal: https://documentation.onesignal.com
- Gmail API: https://developers.google.com/gmail/api

---

**Versión:** 1.0.0
**Fecha:** 2024-11-06
**Autor:** Sistema de Gestión de Reclamos Telco
**Stack:** Flutter + NestJS + PostgreSQL + Supabase + Railway
