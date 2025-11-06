import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import configuration from './config/configuration';
import { PrismaModule } from './prisma/prisma.module';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsuariosModule } from './modules/usuarios/usuarios.module';
import { ReclamosModule } from './modules/reclamos/reclamos.module';
import { NotificacionesModule } from './modules/notificaciones/notificaciones.module';

/**
 * Módulo raíz de la aplicación
 * Configura todos los módulos globales y características principales
 */
@Module({
  imports: [
    // Configuración global - Variables de entorno
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      cache: true,
      expandVariables: true,
      envFilePath: ['.env.local', '.env'],
    }),

    // Rate Limiting - Protección contra DDoS y abuso
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000, // 1 segundo
        limit: 3, // 3 requests por segundo
      },
      {
        name: 'medium',
        ttl: 10000, // 10 segundos
        limit: 20, // 20 requests por 10 segundos
      },
      {
        name: 'long',
        ttl: 60000, // 1 minuto
        limit: 100, // 100 requests por minuto
      },
    ]),

    // Prisma - Database ORM
    PrismaModule,

    // Health Checks
    HealthModule,

    // Módulos de funcionalidad
    AuthModule,
    UsuariosModule,
    ReclamosModule,
    NotificacionesModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
