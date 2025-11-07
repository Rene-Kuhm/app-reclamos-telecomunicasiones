import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

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
    accion: string,
    descripcion: string,
    detalles?: Record<string, any>,
  ): Promise<void> {
    try {
      await this.prisma.auditoriaReclamo.create({
        data: {
          reclamo_id: reclamoId,
          usuario_id: usuarioId,
          accion: accion,
          notas: descripcion,
          campos_cambiados: detalles ? JSON.stringify(detalles) : null,
        },
      });

      this.logger.log(
        `Auditoría registrada: ${accion} - ${descripcion} (Reclamo: ${reclamoId}, Usuario: ${usuarioId})`,
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
      'CAMBIO_ESTADO',
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
      'ASIGNACION',
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
      'REASIGNACION',
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
      'ACTUALIZACION',
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
      'CAMBIO_PRIORIDAD',
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
      'CIERRE',
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
      'RECHAZO',
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
    const auditorias = await this.prisma.auditoriaReclamo.findMany({
      where: { reclamo_id: reclamoId },
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
        created_at: 'desc',
      },
    });

    return auditorias.map((auditoria: any) => ({
      id: auditoria.id,
      accion: auditoria.accion,
      descripcion: auditoria.notas,
      detalles: auditoria.campos_cambiados ? JSON.parse(auditoria.campos_cambiados) : null,
      usuario: {
        nombre: `${auditoria.usuario.nombre} ${auditoria.usuario.apellido}`,
        email: auditoria.usuario.email,
        rol: auditoria.usuario.rol,
      },
      fecha: auditoria.created_at,
    }));
  }

  /**
   * Obtiene estadísticas de auditoría
   */
  async obtenerEstadisticas(fechaInicio?: Date, fechaFin?: Date): Promise<any> {
    const where: Prisma.AuditoriaReclamoWhereInput = {};

    if (fechaInicio || fechaFin) {
      where.created_at = {};
      if (fechaInicio) {
        where.created_at.gte = fechaInicio;
      }
      if (fechaFin) {
        where.created_at.lte = fechaFin;
      }
    }

    const [totalEventos, eventosPorTipo, eventosRecientes] = await Promise.all([
      this.prisma.auditoriaReclamo.count({ where }),
      this.prisma.auditoriaReclamo.groupBy({
        by: ['accion'],
        where,
        _count: true,
      }),
      this.prisma.auditoriaReclamo.findMany({
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
              numero_reclamo: true,
              titulo: true,
            },
          },
        },
        orderBy: {
          created_at: 'desc',
        },
        take: 10,
      }),
    ]);

    return {
      totalEventos,
      eventosPorTipo: eventosPorTipo.reduce((acc: Record<string, number>, curr: any) => {
        acc[curr.accion] = curr._count;
        return acc;
      }, {} as Record<string, number>),
      eventosRecientes: eventosRecientes.map((evento: any) => ({
        accion: evento.accion,
        descripcion: evento.notas,
        usuario: `${evento.usuario.nombre} ${evento.usuario.apellido}`,
        rol: evento.usuario.rol,
        reclamo: evento.reclamo.numero_reclamo,
        fecha: evento.created_at,
      })),
    };
  }
}