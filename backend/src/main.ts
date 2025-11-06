import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as compression from 'compression';
import helmet from 'helmet';
import { AppModule } from './app.module';

/**
 * Bootstrap de la aplicación NestJS
 * Configura middleware de seguridad, validación, compresión y documentación
 */
async function bootstrap() {
  const logger = new Logger('Bootstrap');

  // Crear aplicación NestJS
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'],
  });

  // Obtener servicio de configuración
  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT', 3000);
  const nodeEnv = configService.get<string>('NODE_ENV', 'development');
  const apiPrefix = configService.get<string>('API_PREFIX', 'api/v1');

  // Configurar prefijo global de API
  app.setGlobalPrefix(apiPrefix);

  // CORS - Configuración según entorno
  const allowedOrigins = configService
    .get<string>('ALLOWED_ORIGINS', 'http://localhost:3000')
    .split(',');

  app.enableCors({
    origin: allowedOrigins,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-Requested-With',
      'Accept',
    ],
    exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
  });

  // Helmet - Security headers
  app.use(
    helmet({
      contentSecurityPolicy: nodeEnv === 'production',
      crossOriginEmbedderPolicy: nodeEnv === 'production',
      hsts: {
        maxAge: 31536000, // 1 año
        includeSubDomains: true,
        preload: true,
      },
    }),
  );

  // Compression - Comprimir respuestas HTTP
  app.use(compression());

  // Validation Pipe - Validación automática de DTOs
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Eliminar propiedades no definidas en DTO
      forbidNonWhitelisted: true, // Lanzar error si hay propiedades extra
      transform: true, // Transformar payloads a instancias de DTO
      transformOptions: {
        enableImplicitConversion: true, // Conversión implícita de tipos
      },
      disableErrorMessages: nodeEnv === 'production', // Ocultar mensajes en prod
    }),
  );

  // Swagger Documentation - Solo en desarrollo y staging
  if (nodeEnv !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('API - Sistema de Gestión de Reclamos Telco')
      .setDescription(
        'API REST para gestión interna de reclamos de telecomunicaciones. ' +
          'Soporta Internet ADSL/Fibra, Teléfono Fijo ADSL/Fibra, y TV Sensa.',
      )
      .setVersion('1.0.0')
      .addTag('auth', 'Autenticación y autorización')
      .addTag('usuarios', 'Gestión de usuarios')
      .addTag('reclamos', 'Gestión de reclamos')
      .addTag('notificaciones', 'Sistema de notificaciones')
      .addTag('health', 'Health checks')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Ingrese el JWT access token',
          name: 'Authorization',
          in: 'header',
        },
        'JWT-auth',
      )
      .addServer(`http://localhost:${port}`, 'Desarrollo Local')
      .addServer('https://api-staging.example.com', 'Staging')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api', app, document, {
      swaggerOptions: {
        persistAuthorization: true,
        tagsSorter: 'alpha',
        operationsSorter: 'alpha',
      },
      customSiteTitle: 'API Docs - Reclamos Telco',
    });

    logger.log(`📚 Swagger documentation available at: http://localhost:${port}/api`);
  }

  // Graceful shutdown
  app.enableShutdownHooks();

  // Iniciar servidor
  await app.listen(port);

  logger.log(`🚀 Application is running on: http://localhost:${port}/${apiPrefix}`);
  logger.log(`🌍 Environment: ${nodeEnv}`);
  logger.log(`📡 CORS enabled for: ${allowedOrigins.join(', ')}`);

  // Log de información adicional en desarrollo
  if (nodeEnv === 'development') {
    logger.debug(`🔍 Debug mode enabled`);
    logger.debug(`📊 Health check: http://localhost:${port}/health`);
    logger.debug(`📈 Metrics: http://localhost:${port}/metrics`);
  }
}

// Manejo de errores no capturados
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

bootstrap();
