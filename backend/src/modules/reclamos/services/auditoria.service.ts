import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TipoAuditoria, Prisma } from '@prisma/client';

@Injectable()
export class AuditoriaService {
  private readonly logger = new Logger(AuditoriaService.name);

  constructor(private prisma: PrismaService) {}

  /**
   * Registra un evento de auditoría
   */
  async registrar(
    reclamoId: string,
    usuarioId: string,
    tipo: TipoAuditoria,
    descripcion: string,
    detalles?: Record<string, any>,
  ): Promise<void> {
    try {
      await this.prisma.auditoria.create({
        data: {
          reclamoId,
          usuarioId,
          tipo,
          descripcion,
          detalles: detalles as Prisma.InputJsonValue,
        },
      });

      this.logger.log(
        `Auditoría registrada: ${tipo} - ${descripcion} (Reclamo: ${reclamoId}, Usuario: ${usuarioId})`,
      );
    } catch (error) {
      this.logger.error('Error al registrar auditoría', error);
      // No lanzar error para no interrumpir el flujo principal
    }
  }

  /**
   * Registra cambio de estado
   */
  async registrarCambioEstado(
    reclamoId: string,
    usuarioId: string,
    estadoAnterior: string,
    estadoNuevo: string,
    motivo?: string,
  ): Promise<void> {
    await this.registrar(
      reclamoId,
      usuarioId,
      TipoAuditoria.CAMBIO_ESTADO,
      `Estado cambiado de ${estadoAnterior} a ${estadoNuevo}`,
      {
        estadoAnterior,
        estadoNuevo,
        motivo,
      },
    );
  }

  /**
   * Registra asignación de técnico
   */
  async registrarAsignacion(
    reclamoId: string,
    usuarioId: string,
    tecnicoId: string,
    tecnicoNombre: string,
    notas?: string,
  ): Promise<void> {
    await this.registrar(
      reclamoId,
      usuarioId,
      TipoAuditoria.ASIGNACION,
      `Reclamo asignado a ${tecnicoNombre}`,
      {
        tecnicoId,
        tecnicoNombre,
        notas,
      },
    );
  }

  /**
   * Registra reasignación
   */
  async registrarReasignacion(
    reclamoId: string,
    usuarioId: string,
    tecnicoAnteriorId: string,
    tecnicoAnteriorNombre: string,
    tecnicoNuevoId: string,
    tecnicoNuevoNombre: string,
    motivo?: string,
  ): Promise<void> {
    await this.registrar(
      reclamoId,
      usuarioId,
      TipoAuditoria.REASIGNACION,
      `Reclamo reasignado de ${tecnicoAnteriorNombre} a ${tecnicoNuevoNombre}`,
      {
        tecnicoAnteriorId,
        tecnicoAnteriorNombre,
        tecnicoNuevoId,
        tecnicoNuevoNombre,
        motivo,
      },
    );
  }

  /**
   * Registra actualización de datos
   */
  async registrarActualizacion(
    reclamoId: string,
    usuarioId: string,
    camposActualizados: string[],
    valoresAnteriores?: Record<string, any>,
    valoresNuevos?: Record<string, any>,
  ): Promise<void> {
    await this.registrar(
      reclamoId,
      usuarioId,
      TipoAuditoria.ACTUALIZACION,
      `Campos actualizados: ${camposActualizados.join(', ')}`,
      {
        camposActualizados,
        valoresAnteriores,
        valoresNuevos,
      },
    );
  }

  /**
   * Registra cambio de prioridad
   */
  async registrarCambioPrioridad(
    reclamoId: string,
    usuarioId: string,
    prioridadAnterior: string,
    prioridadNueva: string,
    motivo?: string,
  ): Promise<void> {
    await this.registrar(
      reclamoId,
      usuarioId,
      TipoAuditoria.CAMBIO_PRIORIDAD,
      `Prioridad cambiada de ${prioridadAnterior} a ${prioridadNueva}`,
      {
        prioridadAnterior,
        prioridadNueva,
        motivo,
      },
    );
  }

  /**
   * Registra cierre de reclamo
   */
  async registrarCierre(
    reclamoId: string,
    usuarioId: string,
    solucion: string,
    notasFinales?: string,
  ): Promise<void> {
    await this.registrar(
      reclamoId,
      usuarioId,
      TipoAuditoria.CIERRE,
      'Reclamo cerrado',
      {
        solucion,
        notasFinales,
      },
    );
  }

  /**
   * Registra rechazo de reclamo
   */
  async registrarRechazo(
    reclamoId: string,
    usuarioId: string,
    motivo: string,
  ): Promise<void> {
    await this.registrar(
      reclamoId,
      usuarioId,
      TipoAuditoria.RECHAZO,
      'Reclamo rechazado',
      {
        motivo,
      },
    );
  }

  /**
   * Obtiene el historial de auditoría de un reclamo
   */
  async obtenerHistorial(reclamoId: string): Promise<any[]> {
    const auditorias = await this.prisma.auditoria.findMany({
      where: { reclamoId },
      include: {
        usuario: {
          select: {
            id: true,
            nombre: true,
            apellido: true,
            email: true,
            rol: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return auditorias.map((auditoria) => ({
      id: auditoria.id,
      tipo: auditoria.tipo,
      descripcion: auditoria.descripcion,
      detalles: auditoria.detalles,
      usuario: {
        nombre: `${auditoria.usuario.nombre} ${auditoria.usuario.apellido}`,
        email: auditoria.usuario.email,
        rol: auditoria.usuario.rol,
      },
      fecha: auditoria.createdAt,
    }));
  }

  /**
   * Obtiene estadísticas de auditoría
   */
  async obtenerEstadisticas(fechaInicio?: Date, fechaFin?: Date): Promise<any> {
    const where: Prisma.AuditoriaWhereInput = {};

    if (fechaInicio || fechaFin) {
      where.createdAt = {};
      if (fechaInicio) {
        where.createdAt.gte = fechaInicio;
      }
      if (fechaFin) {
        where.createdAt.lte = fechaFin;
      }
    }

    const [totalEventos, eventosPorTipo, eventosRecientes] = await Promise.all([
      this.prisma.auditoria.count({ where }),
      this.prisma.auditoria.groupBy({
        by: ['tipo'],
        where,
        _count: true,
      }),
      this.prisma.auditoria.findMany({
        where,
        include: {
          usuario: {
            select: {
              nombre: true,
              apellido: true,
              rol: true,
            },
          },
          reclamo: {
            select: {
              codigo: true,
              titulo: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
        take: 10,
      }),
    ]);

    return {
      totalEventos,
      eventosPorTipo: eventosPorTipo.reduce((acc, curr) => {
        acc[curr.tipo] = curr._count;
        return acc;
      }, {}),
      eventosRecientes: eventosRecientes.map((evento) => ({
        tipo: evento.tipo,
        descripcion: evento.descripcion,
        usuario: `${evento.usuario.nombre} ${evento.usuario.apellido}`,
        rol: evento.usuario.rol,
        reclamo: evento.reclamo.codigo,
        fecha: evento.createdAt,
      })),
    };
  }
}