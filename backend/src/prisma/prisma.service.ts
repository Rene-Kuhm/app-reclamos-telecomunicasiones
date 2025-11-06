import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/**
 * Servicio de Prisma ORM
 * Gestiona la conexión a la base de datos PostgreSQL
 * Implementa hooks de ciclo de vida para conectar/desconectar
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super({
      log: [
        {
          emit: 'event',
          level: 'query',
        },
        {
          emit: 'event',
          level: 'error',
        },
        {
          emit: 'event',
          level: 'info',
        },
        {
          emit: 'event',
          level: 'warn',
        },
      ],
      errorFormat: 'pretty',
    });

    // Log de queries en desarrollo
    if (process.env.NODE_ENV === 'development') {
      // @ts-ignore
      this.$on('query', (e) => {
        this.logger.debug(`Query: ${e.query}`);
        this.logger.debug(`Params: ${e.params}`);
        this.logger.debug(`Duration: ${e.duration}ms`);
      });
    }

    // Log de errores
    // @ts-ignore
    this.$on('error', (e) => {
      this.logger.error(`Error: ${e.message}`);
    });

    // Log de warnings
    // @ts-ignore
    this.$on('warn', (e) => {
      this.logger.warn(`Warning: ${e.message}`);
    });
  }

  /**
   * Hook ejecutado cuando el módulo se inicializa
   * Conecta a la base de datos
   */
  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('✅ Database connection established');
    } catch (error) {
      this.logger.error('❌ Failed to connect to database', error);
      throw error;
    }
  }

  /**
   * Hook ejecutado cuando el módulo se destruye
   * Desconecta de la base de datos
   */
  async onModuleDestroy() {
    try {
      await this.$disconnect();
      this.logger.log('✅ Database connection closed');
    } catch (error) {
      this.logger.error('❌ Failed to disconnect from database', error);
      throw error;
    }
  }

  /**
   * Método helper para limpiar base de datos
   * Solo disponible en entorno de testing
   */
  async cleanDatabase() {
    if (process.env.NODE_ENV !== 'test') {
      throw new Error('cleanDatabase() only available in test environment');
    }

    const models = Reflect.ownKeys(this).filter(
      (key) => typeof key === 'string' && key[0] !== '_' && key[0] !== '$',
    );

    return Promise.all(
      models.map((modelKey) => {
        const model = this[modelKey as string];
        if (model && typeof model.deleteMany === 'function') {
          return model.deleteMany();
        }
      }),
    );
  }

  /**
   * Método helper para ejecutar transacciones de forma segura
   */
  async executeTransaction<T>(
    fn: (prisma: Omit<PrismaClient, '$connect' | '$disconnect' | '$on' | '$transaction' | '$use'>) => Promise<T>,
  ): Promise<T> {
    return this.$transaction(fn);
  }
}
