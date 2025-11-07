import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { RolUsuario, EstadoUsuario, EstadoReclamo } from '../../../common/types/prisma-enums';

@Injectable()
export class AsignacionService {
  private readonly logger = new Logger(AsignacionService.name);

  constructor(private prisma: PrismaService) {}

  /**
   * Asigna automáticamente un técnico al reclamo basado en disponibilidad
   */
  async asignarTecnicoAutomaticamente(
    reclamoId: string,
  ): Promise<string | null> {
    try {
      // Buscar técnicos disponibles (con menos reclamos asignados)
      const tecnicos = await this.prisma.usuario.findMany({
        where: {
          rol: RolUsuario.TECNICO,
          activo: true,
          deleted_at: null,
        },
        include: {
          _count: {
            select: {
              reclamos_asignados: {
                where: {
                  estado: {
                    in: [
                      EstadoReclamo.ASIGNADO,
                      EstadoReclamo.EN_CURSO,
                      EstadoReclamo.EN_REVISION,
                    ],
                  },
                },
              },
            },
          },
        },
        orderBy: {
          reclamos_asignados: {
            _count: 'asc',
          },
        },
      });

      if (tecnicos.length === 0) {
        this.logger.warn(
          `No hay técnicos disponibles para asignar al reclamo ${reclamoId}`,
        );
        return null;
      }

      // Seleccionar el técnico con menos reclamos activos
      const tecnicoSeleccionado = tecnicos[0];

      this.logger.log(
        `Técnico ${tecnicoSeleccionado.nombre} ${tecnicoSeleccionado.apellido} asignado automáticamente al reclamo ${reclamoId}`,
      );

      return tecnicoSeleccionado.id;
    } catch (error) {
      this.logger.error('Error al asignar técnico automáticamente', error);
      return null;
    }
  }

  /**
   * Obtiene estadísticas de carga de trabajo de técnicos
   */
  async obtenerCargaTecnicos(): Promise<any[]> {
    const tecnicos = await this.prisma.usuario.findMany({
      where: {
        rol: RolUsuario.TECNICO,
        activo: true,
        deleted_at: null,
      },
      select: {
        id: true,
        nombre: true,
        apellido: true,
        email: true,
        _count: {
          select: {
            reclamos_asignados: {
              where: {
                estado: {
                  in: [
                    EstadoReclamo.ASIGNADO,
                    EstadoReclamo.EN_CURSO,
                    EstadoReclamo.EN_REVISION,
                  ],
                },
              },
            },
          },
        },
        reclamos_asignados: {
          where: {
            estado: {
              in: [
                EstadoReclamo.ASIGNADO,
                EstadoReclamo.EN_CURSO,
                EstadoReclamo.EN_REVISION,
              ],
            },
          },
          select: {
            id: true,
            numero_reclamo: true,
            titulo: true,
            estado: true,
            prioridad: true,
            created_at: true,
          },
          take: 10,
          orderBy: {
            prioridad: 'desc',
          },
        },
      },
    });

    return tecnicos.map((tecnico) => ({
      id: tecnico.id,
      nombre: `${tecnico.nombre} ${tecnico.apellido}`,
      email: tecnico.email,
      reclamosActivos: tecnico._count.reclamos_asignados,
      reclamos: tecnico.reclamos_asignados,
    }));
  }

  /**
   * Reasigna reclamos de un técnico a otros técnicos
   */
  async reasignarReclamosDeTecnico(
    tecnicoId: string,
    nuevoTecnicoId?: string,
  ): Promise<number> {
    // Verificar que el técnico existe
    const tecnico = await this.prisma.usuario.findUnique({
      where: { id: tecnicoId },
    });

    if (!tecnico || tecnico.rol !== RolUsuario.TECNICO) {
      throw new NotFoundException('Técnico no encontrado');
    }

    // Obtener reclamos activos del técnico
    const reclamosActivos = await this.prisma.reclamo.findMany({
      where: {
        id_tecnico_asignado: tecnicoId,
        estado: {
          in: [
            EstadoReclamo.ASIGNADO,
            EstadoReclamo.EN_CURSO,
            EstadoReclamo.EN_REVISION,
          ],
        },
      },
    });

    if (reclamosActivos.length === 0) {
      return 0;
    }

    let contador = 0;

    // Si se especificó un nuevo técnico, reasignar todos a ese técnico
    if (nuevoTecnicoId) {
      const nuevoTecnico = await this.prisma.usuario.findUnique({
        where: { id: nuevoTecnicoId },
      });

      if (!nuevoTecnico || nuevoTecnico.rol !== RolUsuario.TECNICO) {
        throw new NotFoundException('Nuevo técnico no encontrado');
      }

      await this.prisma.reclamo.updateMany({
        where: {
          id: {
            in: reclamosActivos.map((r) => r.id),
          },
        },
        data: {
          id_tecnico_asignado: nuevoTecnicoId,
        },
      });

      contador = reclamosActivos.length;
    } else {
      // Reasignar automáticamente cada reclamo
      for (const reclamo of reclamosActivos) {
        const nuevoTecnico =
          await this.asignarTecnicoAutomaticamente(reclamo.id);

        if (nuevoTecnico) {
          await this.prisma.reclamo.update({
            where: { id: reclamo.id },
            data: { id_tecnico_asignado: nuevoTecnico },
          });
          contador++;
        }
      }
    }

    this.logger.log(
      `${contador} reclamos reasignados del técnico ${tecnicoId}`,
    );

    return contador;
  }

  /**
   * Obtiene recomendación de técnico para un reclamo específico
   */
  async recomendarTecnico(reclamoId: string): Promise<any> {
    const reclamo = await this.prisma.reclamo.findUnique({
      where: { id: reclamoId },
    });

    if (!reclamo) {
      throw new NotFoundException('Reclamo no encontrado');
    }

    const cargaTecnicos = await this.obtenerCargaTecnicos();

    // Ordenar por carga de trabajo (menos reclamos primero)
    const tecnicosOrdenados = cargaTecnicos.sort(
      (a, b) => a.reclamosActivos - b.reclamosActivos,
    );

    return {
      recomendado: tecnicosOrdenados[0],
      alternativas: tecnicosOrdenados.slice(1, 4),
      criterio: 'Menor carga de trabajo',
    };
  }
}