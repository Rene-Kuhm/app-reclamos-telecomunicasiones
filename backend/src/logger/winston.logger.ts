import { LoggerService } from '@nestjs/common';
import { createLogger, format, transports, Logger as WinstonLoggerInstance } from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import * as path from 'path';

/**
 * Logger personalizado con Winston
 * Implementa LoggerService de NestJS para integración completa
 * Características:
 * - Rotación diaria de logs
 * - Niveles de log configurables
 * - Formato estructurado (JSON)
 * - Logs separados por nivel (error, combined)
 */
export class WinstonLogger implements LoggerService {
  private logger: WinstonLoggerInstance;
  private context?: string;

  constructor(context?: string) {
    this.context = context;

    const logLevel = process.env.LOG_LEVEL || 'info';
    const nodeEnv = process.env.NODE_ENV || 'development';

    // Formato base para todos los transportes
    const baseFormat = format.combine(
      format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
      format.errors({ stack: true }),
      format.splat(),
    );

    // Formato para archivos (JSON estructurado)
    const fileFormat = format.combine(
      baseFormat,
      format.json(),
    );

    // Formato para consola (colorizado y legible)
    const consoleFormat = format.combine(
      baseFormat,
      format.colorize(),
      format.printf(({ timestamp, level, message, context, trace, ...meta }) => {
        const metaStr = Object.keys(meta).length ? `\n${JSON.stringify(meta, null, 2)}` : '';
        const traceStr = trace ? `\n${trace}` : '';
        return `${timestamp} [${context || 'Application'}] ${level}: ${message}${metaStr}${traceStr}`;
      }),
    );

    // Crear directorio de logs si no existe
    const logsDir = path.join(process.cwd(), 'logs');

    // Configurar transportes
    const logTransports: any[] = [];

    // Transport para archivo de errores (rotación diaria)
    logTransports.push(
      new DailyRotateFile({
        filename: path.join(logsDir, 'error-%DATE%.log'),
        datePattern: 'YYYY-MM-DD',
        level: 'error',
        format: fileFormat,
        maxSize: '20m',
        maxFiles: '30d',
        zippedArchive: true,
      }),
    );

    // Transport para archivo combinado (rotación diaria)
    logTransports.push(
      new DailyRotateFile({
        filename: path.join(logsDir, 'combined-%DATE%.log'),
        datePattern: 'YYYY-MM-DD',
        format: fileFormat,
        maxSize: '20m',
        maxFiles: '14d',
        zippedArchive: true,
      }),
    );

    // Transport para consola (solo en desarrollo)
    if (nodeEnv !== 'production') {
      logTransports.push(
        new transports.Console({
          format: consoleFormat,
        }),
      );
    }

    // Crear instancia de logger
    this.logger = createLogger({
      level: logLevel,
      format: baseFormat,
      defaultMeta: {
        service: process.env.APP_NAME || 'reclamos-telco-api',
        environment: nodeEnv,
        version: process.env.APP_VERSION || '1.0.0',
      },
      transports: logTransports,
      exitOnError: false,
    });

    // Capturar excepciones no manejadas
    this.logger.exceptions.handle(
      new DailyRotateFile({
        filename: path.join(logsDir, 'exceptions-%DATE%.log'),
        datePattern: 'YYYY-MM-DD',
        maxSize: '20m',
        maxFiles: '30d',
        format: fileFormat,
      }),
    );

    // Capturar rechazos de promesas no manejadas
    this.logger.rejections.handle(
      new DailyRotateFile({
        filename: path.join(logsDir, 'rejections-%DATE%.log'),
        datePattern: 'YYYY-MM-DD',
        maxSize: '20m',
        maxFiles: '30d',
        format: fileFormat,
      }),
    );
  }

  /**
   * Log de nivel info
   */
  log(message: any, context?: string) {
    this.logger.info(message, { context: context || this.context });
  }

  /**
   * Log de nivel error
   */
  error(message: any, trace?: string, context?: string) {
    this.logger.error(message, {
      context: context || this.context,
      trace,
    });
  }

  /**
   * Log de nivel warn
   */
  warn(message: any, context?: string) {
    this.logger.warn(message, { context: context || this.context });
  }

  /**
   * Log de nivel debug
   */
  debug(message: any, context?: string) {
    this.logger.debug(message, { context: context || this.context });
  }

  /**
   * Log de nivel verbose
   */
  verbose(message: any, context?: string) {
    this.logger.verbose(message, { context: context || this.context });
  }

  /**
   * Log con metadata adicional
   */
  logWithMeta(level: string, message: string, meta: any, context?: string) {
    this.logger.log(level, message, {
      context: context || this.context,
      ...meta,
    });
  }

  /**
   * Crear un child logger con contexto específico
   */
  child(context: string): WinstonLogger {
    return new WinstonLogger(context);
  }

  /**
   * Obtener la instancia de Winston logger
   */
  getWinstonLogger(): WinstonLoggerInstance {
    return this.logger;
  }
}

// Export de instancia singleton para uso global
export const logger = new WinstonLogger();
