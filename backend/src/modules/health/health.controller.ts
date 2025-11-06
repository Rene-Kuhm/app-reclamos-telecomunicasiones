import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import {
  HealthCheck,
  HealthCheckService,
  PrismaHealthIndicator,
  MemoryHealthIndicator,
  DiskHealthIndicator,
} from '@nestjs/terminus';
import { PrismaService } from '../../prisma/prisma.service';

/**
 * Controlador de Health Checks
 * Provee endpoints para monitoreo de salud de la aplicación
 * Útil para Kubernetes liveness/readiness probes
 */
@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private prismaHealth: PrismaHealthIndicator,
    private memory: MemoryHealthIndicator,
    private disk: DiskHealthIndicator,
    private prisma: PrismaService,
  ) {}

  /**
   * Health check completo
   * Verifica: Database, Memory, Disk
   */
  @Get()
  @HealthCheck()
  @ApiOperation({ summary: 'Health check completo' })
  @ApiResponse({ status: 200, description: 'Servicio saludable' })
  @ApiResponse({ status: 503, description: 'Servicio con problemas' })
  check() {
    return this.health.check([
      // Verificar conexión a base de datos
      () => this.prismaHealth.pingCheck('database', this.prisma),

      // Verificar memoria heap (alerta si usa >150MB)
      () => this.memory.checkHeap('memory_heap', 150 * 1024 * 1024),

      // Verificar memoria RSS (alerta si usa >300MB)
      () => this.memory.checkRSS('memory_rss', 300 * 1024 * 1024),

      // Verificar espacio en disco (alerta si quedan <10GB)
      () =>
        this.disk.checkStorage('storage', {
          path: '/',
          thresholdPercent: 0.9, // 90% usado
        }),
    ]);
  }

  /**
   * Readiness probe
   * Verifica que el servicio está listo para recibir tráfico
   * Kubernetes usa este endpoint para saber cuándo enrutar requests
   */
  @Get('ready')
  @HealthCheck()
  @ApiOperation({ summary: 'Readiness probe para Kubernetes' })
  @ApiResponse({ status: 200, description: 'Servicio listo' })
  @ApiResponse({ status: 503, description: 'Servicio no listo' })
  readiness() {
    return this.health.check([
      // Solo verificamos servicios críticos para estar "ready"
      () => this.prismaHealth.pingCheck('database', this.prisma),
      // Agregar checks de Redis, servicios externos, etc.
    ]);
  }

  /**
   * Liveness probe
   * Verifica que el proceso está vivo
   * Kubernetes usa este endpoint para reiniciar el pod si falla
   */
  @Get('live')
  @ApiOperation({ summary: 'Liveness probe para Kubernetes' })
  @ApiResponse({ status: 200, description: 'Proceso vivo' })
  liveness() {
    // Simple check de que el proceso responde
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
    };
  }

  /**
   * Información de la aplicación
   */
  @Get('info')
  @ApiOperation({ summary: 'Información de la aplicación' })
  @ApiResponse({ status: 200, description: 'Información del servicio' })
  info() {
    return {
      name: process.env.APP_NAME || 'Reclamos Telco API',
      version: process.env.APP_VERSION || '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      nodeVersion: process.version,
      platform: process.platform,
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
    };
  }
}
