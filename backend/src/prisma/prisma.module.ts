import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

/**
 * Módulo de Prisma
 * Declarado como Global para estar disponible en toda la aplicación
 * sin necesidad de importarlo en cada módulo
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
