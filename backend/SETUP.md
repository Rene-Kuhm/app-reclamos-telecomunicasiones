# Guía de Setup del Backend

Esta guía te llevará paso a paso para tener el backend funcionando localmente.

## Requisitos Previos

- **Node.js 20 LTS** - [Descargar](https://nodejs.org/)
- **npm** o **yarn** - Incluido con Node.js
- **Git** - Para clonar el repositorio
- **PostgreSQL 15+** - O cuenta de Supabase (recomendado)

## Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/Rene-Kuhm/app-reclamos-telecomunicasiones.git
cd "app-reclamos-telecomunicasiones"
cd backend
```

## Paso 2: Instalar Dependencias

```bash
npm install
```

Esto instalará:
- NestJS y todas sus dependencias
- Prisma ORM
- Passport para autenticación
- Winston para logging
- Y 40+ paquetes más

**Tiempo estimado:** 2-3 minutos

## Paso 3: Configurar Supabase (Base de Datos)

### Opción A: Usar Supabase (Recomendado - Gratis)

1. Ir a https://supabase.com y crear cuenta
2. Crear nuevo proyecto:
   - Project name: `reclamos-telco`
   - Database Password: Guardar en lugar seguro
   - Region: South America (São Paulo) - más cercano a Argentina

3. Esperar a que el proyecto se inicialice (2-3 minutos)

4. Obtener la URL de conexión:
   - Ir a: Settings → Database
   - Copiar el string de "Connection string" con el modo "URI"
   - Debería verse así: `postgresql://postgres.[proyecto]:[password]@aws-0-sa-east-1.pooler.supabase.com:6543/postgres`

### Opción B: PostgreSQL Local

```bash
# Instalar PostgreSQL 15
# En Windows: usar el instalador desde postgresql.org
# En Linux: sudo apt install postgresql-15

# Crear base de datos
psql -U postgres
CREATE DATABASE reclamos_telco;
CREATE USER reclamos_user WITH PASSWORD 'tu_password';
GRANT ALL PRIVILEGES ON DATABASE reclamos_telco TO reclamos_user;
\q
```

Tu `DATABASE_URL` será:
```
postgresql://reclamos_user:tu_password@localhost:5432/reclamos_telco
```

## Paso 4: Configurar Variables de Entorno

```bash
# Copiar el archivo de ejemplo
cp .env.example .env

# Abrir .env con tu editor favorito
code .env  # VS Code
# o
notepad .env  # Notepad
```

### Variables OBLIGATORIAS para empezar:

```env
# Node Environment
NODE_ENV=development
PORT=3000

# Database (REEMPLAZAR con tu URL de Supabase)
DATABASE_URL="postgresql://postgres.[tu-proyecto]:[tu-password]@aws-0-sa-east-1.pooler.supabase.com:6543/postgres"

# JWT Secret (CAMBIAR por algo seguro)
JWT_SECRET=tu-super-secreto-cambiar-en-produccion-123456
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d
```

### Variables OPCIONALES (puedes dejarlas comentadas por ahora):

```env
# Telegram Bot (para notificaciones - opcional)
# TELEGRAM_BOT_TOKEN=tu-token-de-botfather

# Gmail SMTP (para emails - opcional)
# SMTP_USER=tu-email@gmail.com
# SMTP_PASSWORD=tu-app-password

# OneSignal (para push notifications - opcional)
# ONESIGNAL_APP_ID=tu-app-id
# ONESIGNAL_API_KEY=tu-api-key
```

## Paso 5: Generar Cliente de Prisma

```bash
npm run prisma:generate
```

Esto genera el cliente de Prisma basado en el schema.
Verás output como: "✔ Generated Prisma Client"

## Paso 6: Ejecutar Migraciones

```bash
npm run prisma:migrate
```

Esto:
1. Crea todas las tablas en la base de datos (11 tablas)
2. Guarda la migración en `prisma/migrations/`
3. Aplica la migración

**Salida esperada:**
```
✔ Name of migration: init
The following migration(s) have been created and applied:
  migrations/
    └─ 20240106000000_init/
      └─ migration.sql
✔ Generated Prisma Client
```

## Paso 7: (Opcional) Sembrar Datos de Prueba

```bash
npm run prisma:seed
```

Esto creará:
- 1 usuario Admin
- 1 usuario Supervisor
- 2 usuarios Técnicos
- 3 usuarios Profesionales
- 5 reclamos de ejemplo

**Credenciales de prueba:**
- Admin: `admin@reclamos.com` / `Admin123!`
- Supervisor: `supervisor@reclamos.com` / `Super123!`
- Técnico: `tecnico1@reclamos.com` / `Tecnico123!`
- Profesional: `profesional1@reclamos.com` / `Profesional123!`

## Paso 8: Iniciar el Servidor

```bash
npm run start:dev
```

Verás algo como:
```
[Nest] 12345  - 01/06/2024, 10:00:00 AM     LOG [NestFactory] Starting Nest application...
[Nest] 12345  - 01/06/2024, 10:00:01 AM     LOG [InstanceLoader] AppModule dependencies initialized
[Nest] 12345  - 01/06/2024, 10:00:01 AM     LOG [RoutesResolver] HealthController {/health}:
[Nest] 12345  - 01/06/2024, 10:00:01 AM     LOG [RouterExplorer] Mapped {/health, GET} route
[Nest] 12345  - 01/06/2024, 10:00:01 AM     LOG [Bootstrap] 🚀 Application is running on: http://localhost:3000/api/v1
[Nest] 12345  - 01/06/2024, 10:00:01 AM     LOG [Bootstrap] 📚 Swagger documentation available at: http://localhost:3000/api
```

## Paso 9: Verificar que Funciona

Abre tu navegador en estas URLs:

### 1. Health Check Básico
```
http://localhost:3000/health
```

Deberías ver:
```json
{
  "status": "ok",
  "info": {
    "database": { "status": "up" },
    "memory_heap": { "status": "up" },
    "memory_rss": { "status": "up" },
    "storage": { "status": "up" }
  }
}
```

### 2. Información de la App
```
http://localhost:3000/health/info
```

Deberías ver:
```json
{
  "name": "Sistema de Reclamos Telco",
  "version": "1.0.0",
  "environment": "development",
  "nodeVersion": "v20.x.x",
  "uptime": 5.123
}
```

### 3. Documentación Swagger
```
http://localhost:3000/api
```

Verás la documentación interactiva de la API.

## Paso 10: Explorar la Base de Datos (Opcional)

```bash
npm run prisma:studio
```

Esto abre Prisma Studio en `http://localhost:5555` donde puedes:
- Ver todas las tablas
- Editar datos
- Ejecutar queries
- Explorar relaciones

## Comandos Útiles

```bash
# Desarrollo
npm run start:dev          # Iniciar con hot-reload
npm run start:debug        # Iniciar en modo debug

# Prisma
npm run prisma:studio      # Abrir Prisma Studio
npm run prisma:generate    # Regenerar cliente Prisma
npm run prisma:migrate     # Crear y aplicar migración

# Calidad de código
npm run lint               # Ejecutar ESLint
npm run format             # Formatear con Prettier
npm run type-check         # Verificar tipos TypeScript

# Testing
npm run test               # Ejecutar tests
npm run test:watch         # Tests en modo watch
npm run test:cov           # Tests con coverage
```

## Troubleshooting

### Error: Cannot connect to database

**Problema:** `Error: Can't reach database server`

**Solución:**
1. Verificar que `DATABASE_URL` en `.env` es correcta
2. Verificar que Supabase está activo (no pausado)
3. Verificar conectividad a internet
4. Intentar con el connection string directo (no pooler):
   ```
   postgresql://postgres:[password]@db.[proyecto].supabase.co:5432/postgres
   ```

### Error: Prisma Client not generated

**Problema:** `Cannot find module '@prisma/client'`

**Solución:**
```bash
npm run prisma:generate
```

### Error: Module not found

**Problema:** Errores de módulos faltantes

**Solución:**
```bash
rm -rf node_modules package-lock.json
npm install
```

### Puerto 3000 ya en uso

**Problema:** `Port 3000 is already in use`

**Solución:**
```bash
# Cambiar puerto en .env
PORT=3001

# O matar el proceso en puerto 3000
# Windows:
netstat -ano | findstr :3000
taskkill /PID [numero_pid] /F

# Linux/Mac:
lsof -ti:3000 | xargs kill -9
```

### Error de permisos en logs/

**Problema:** `EACCES: permission denied, mkdir 'logs'`

**Solución:**
```bash
mkdir logs
# Darle permisos de escritura
```

## Próximos Pasos

Una vez que tengas el backend funcionando:

1. **Implementar Autenticación:**
   - Módulo de Auth con JWT
   - Estrategias de Passport
   - Guards de autorización

2. **Implementar Módulos de Negocio:**
   - Usuarios CRUD
   - Reclamos con workflow completo
   - Notificaciones multi-canal

3. **Configurar Servicios Externos:**
   - Telegram Bot
   - Gmail SMTP
   - OneSignal

4. **Testing:**
   - Tests unitarios
   - Tests de integración
   - Tests E2E

5. **Frontend Flutter:**
   - Inicializar proyecto
   - Conectar con backend
   - Implementar UI

## Recursos Adicionales

- [Documentación de NestJS](https://docs.nestjs.com)
- [Documentación de Prisma](https://www.prisma.io/docs)
- [Documentación de Supabase](https://supabase.com/docs)
- [Arquitectura del Sistema](../docs/ARCHITECTURE.md)

## Soporte

Si tienes problemas, puedes:
1. Revisar los logs en `logs/combined-YYYY-MM-DD.log`
2. Verificar que todas las variables de entorno están configuradas
3. Crear un issue en GitHub con el error completo

---

**¡Felicitaciones!** 🎉 Tu backend está funcionando.

Ahora puedes empezar a desarrollar los módulos de autenticación y reclamos.
