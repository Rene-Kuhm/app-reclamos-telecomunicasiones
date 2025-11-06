import { Module } from '@nestjs/common';
import { ReclamosService } from './reclamos.service';
import { ReclamosController } from './reclamos.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { WorkflowService } from './services/workflow.service';
import { AsignacionService } from './services/asignacion.service';
import { AuditoriaService } from './services/auditoria.service';
import { ComentariosService } from './services/comentarios.service';
import { ArchivosService } from './services/archivos.service';

@Module({
  imports: [PrismaModule],
  controllers: [ReclamosController],
  providers: [
    ReclamosService,
    WorkflowService,
    AsignacionService,
    AuditoriaService,
    ComentariosService,
    ArchivosService,
  ],
  exports: [
    ReclamosService,
    WorkflowService,
    AsignacionService,
    AuditoriaService,
  ],
})
export class ReclamosModule {}