# Backend - Sistema de Gestión de Reclamos Telco

Backend enterprise-grade construido con **NestJS 10**, **Prisma ORM**, y **PostgreSQL** (Supabase).

## Stack Tecnológico

- **Framework:** NestJS 10.3.0
- **Language:** TypeScript 5.3.3
- **Database:** PostgreSQL 15+ (Supabase)
- **ORM:** Prisma 5.8.0
- **Authentication:** JWT + Refresh Tokens + MFA (TOTP)
- **Validation:** class-validator + class-transformer
- **Documentation:** Swagger/OpenAPI 3.0
- **Testing:** Jest + Supertest
- **Logging:** Winston
- **Monitoring:** Sentry
- **Queue:** Bull + Redis

## Requisitos Previos

- Node.js 20 LTS o superior
- npm o yarn
- PostgreSQL 15+ (o cuenta de Supabase)
- Redis (opcional, para queues y cache)

## Instalación

```bash
# 1. Instalar dependencias
npm install

# 2. Copiar archivo de entorno
cp .env.example .env

# 3. Configurar variables de entorno en .env
# Editar DATABASE_URL, JWT_SECRET, etc.

# 4. Generar cliente de Prisma
npm run prisma:generate

# 5. Ejecutar migraciones
npm run prisma:migrate

# 6. Sembrar datos iniciales (opcional)
npm run prisma:seed
```

## Desarrollo

```bash
# Modo desarrollo con hot-reload
npm run start:dev

# Modo debug
npm run start:debug

# Ver base de datos con Prisma Studio
npm run prisma:studio
```

El servidor estará disponible en `http://localhost:3000`

Documentación de la API (Swagger): `http://localhost:3000/api`

## Scripts Disponibles

```bash
# Desarrollo
npm run start:dev          # Iniciar con hot-reload
npm run start:debug        # Iniciar en modo debug

# Build y producción
npm run build              # Compilar proyecto
npm run start:prod         # Iniciar en producción

# Calidad de código
npm run lint               # Ejecutar ESLint
npm run format             # Formatear código con Prettier
npm run type-check         # Verificar tipos TypeScript

# Testing
npm run test               # Tests unitarios
npm run test:watch         # Tests en modo watch
npm run test:cov           # Tests con coverage
npm run test:e2e           # Tests end-to-end

# Prisma
npm run prisma:generate    # Generar cliente Prisma
npm run prisma:migrate     # Crear y aplicar migración
npm run prisma:studio      # Abrir Prisma Studio
npm run prisma:seed        # Sembrar datos
```

## Estructura del Proyecto

```
backend/
├── src/
│   ├── main.ts                      # Entry point
│   ├── app.module.ts                # Root module
│   │
│   ├── common/                      # Shared utilities
│   │   ├── decorators/              # Custom decorators
│   │   ├── filters/                 # Exception filters
│   │   ├── guards/                  # Auth & RBAC guards
│   │   ├── interceptors/            # Logging, transform
│   │   ├── pipes/                   # Validation pipes
│   │   └── utils/                   # Helpers
│   │
│   ├── config/                      # Configuration
│   │   ├── configuration.ts         # Env variables
│   │   ├── database.config.ts
│   │   └── jwt.config.ts
│   │
│   └── modules/                     # Feature modules
│       ├── auth/                    # Authentication
│       ├── usuarios/                # User management
│       ├── reclamos/                # Claims management
│       ├── notificaciones/          # Notifications
│       ├── files/                   # File handling
│       └── health/                  # Health checks
│
├── prisma/
│   ├── schema.prisma                # Database schema
│   ├── migrations/                  # Migration files
│   └── seeds/                       # Seed scripts
│
├── test/
│   ├── unit/                        # Unit tests
│   ├── integration/                 # Integration tests
│   └── e2e/                         # E2E tests
│
└── logs/                            # Application logs
```

## API Endpoints

### Autenticación
```
POST   /api/v1/auth/register         # Registro de usuario
POST   /api/v1/auth/login            # Login
POST   /api/v1/auth/logout           # Logout
POST   /api/v1/auth/refresh          # Renovar access token
POST   /api/v1/auth/forgot-password  # Solicitar reset de contraseña
POST   /api/v1/auth/reset-password   # Resetear contraseña
POST   /api/v1/auth/verify-email     # Verificar email
```

### Usuarios
```
GET    /api/v1/usuarios              # Listar usuarios
GET    /api/v1/usuarios/me           # Perfil actual
PATCH  /api/v1/usuarios/me           # Actualizar perfil
PATCH  /api/v1/usuarios/me/password  # Cambiar contraseña
```

### Reclamos
```
GET    /api/v1/reclamos              # Listar reclamos
POST   /api/v1/reclamos              # Crear reclamo
GET    /api/v1/reclamos/:id          # Obtener reclamo
PATCH  /api/v1/reclamos/:id          # Actualizar reclamo
POST   /api/v1/reclamos/:id/asignar  # Asignar técnico
POST   /api/v1/reclamos/:id/cerrar   # Cerrar reclamo
```

### Health & Monitoring
```
GET    /health                       # Health check básico
GET    /health/ready                 # Readiness probe
GET    /health/live                  # Liveness probe
GET    /metrics                      # Métricas Prometheus
```

## Variables de Entorno

Ver `.env.example` para la lista completa de variables requeridas.

### Variables Críticas:
- `DATABASE_URL`: Conexión a PostgreSQL
- `JWT_SECRET`: Secreto para firmar JWT tokens
- `REDIS_URL`: Conexión a Redis (opcional)
- `TELEGRAM_BOT_TOKEN`: Token del bot de Telegram
- `SMTP_USER` y `SMTP_PASSWORD`: Credenciales de email
- `ONESIGNAL_APP_ID` y `ONESIGNAL_API_KEY`: OneSignal para push

## Seguridad

### Implementaciones de Seguridad (OWASP Top 10):

1. **Broken Access Control**: RBAC con guards personalizados
2. **Cryptographic Failures**: Bcrypt (12 rounds) para passwords
3. **Injection**: Prisma ORM previene SQL injection automáticamente
4. **Insecure Design**: Rate limiting con Throttler
5. **Security Misconfiguration**: Helmet para headers de seguridad
6. **Authentication Failures**: JWT + MFA opcional
7. **Logging & Monitoring**: Winston + Sentry

### Rate Limiting
- Global: 10 requests por minuto
- Login: 3 intentos por minuto
- API críticas: Límites personalizados

### CORS
Configurado para permitir solo dominios específicos definidos en `ALLOWED_ORIGINS`.

## Testing

```bash
# Ejecutar todos los tests
npm test

# Tests con coverage (objetivo: >80%)
npm run test:cov

# Tests E2E
npm run test:e2e
```

## Deployment

### Desarrollo Local
```bash
npm run start:dev
```

### Producción (Railway)
```bash
# Build
npm run build

# Ejecutar migraciones
npm run prisma:migrate:deploy

# Iniciar
npm run start:prod
```

### Variables de Entorno en Producción
Asegúrate de configurar todas las variables de entorno en Railway o tu plataforma de hosting.

## Troubleshooting

### Error: Cannot connect to database
- Verificar `DATABASE_URL` en `.env`
- Verificar que PostgreSQL esté corriendo
- Verificar firewall y reglas de red

### Error: Prisma Client not generated
```bash
npm run prisma:generate
```

### Error: Module not found
```bash
rm -rf node_modules package-lock.json
npm install
```

## Documentación Adicional

- [Arquitectura del Sistema](../docs/ARCHITECTURE.md)
- [API Documentation](http://localhost:3000/api) (Swagger)
- [Database Schema](./prisma/schema.prisma)

## Soporte

Para reportar bugs o solicitar features, crear un issue en el repositorio.

## Licencia

Propietario - Uso interno únicamente
