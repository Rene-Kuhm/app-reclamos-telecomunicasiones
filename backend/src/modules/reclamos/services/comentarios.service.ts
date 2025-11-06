import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateComentarioDto } from '../dto';
import { Role } from '@prisma/client';

@Injectable()
export class ComentariosService {
  private readonly logger = new Logger(ComentariosService.name);

  constructor(private prisma: PrismaService) {}

  async create(
    reclamoId: string,
    usuarioId: string,
    createComentarioDto: CreateComentarioDto,
  ) {
    // Verificar que el reclamo existe
    const reclamo = await this.prisma.reclamo.findUnique({
      where: { id: reclamoId },
    });

    if (!reclamo) {
      throw new NotFoundException('Reclamo no encontrado');
    }

    const comentario = await this.prisma.comentario.create({
      data: {
        reclamoId,
        usuarioId,
        contenido: createComentarioDto.contenido,
        interno: createComentarioDto.interno || false,
      },
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
    });

    this.logger.log(
      `Comentario creado en reclamo ${reclamoId} por usuario ${usuarioId}`,
    );

    return {
      id: comentario.id,
      contenido: comentario.contenido,
      interno: comentario.interno,
      usuario: {
        nombre: `${comentario.usuario.nombre} ${comentario.usuario.apellido}`,
        email: comentario.usuario.email,
        rol: comentario.usuario.rol,
      },
      createdAt: comentario.createdAt,
      updatedAt: comentario.updatedAt,
    };
  }

  async findAll(reclamoId: string, usuarioRol: Role, incluirInternos: boolean = true) {
    // Verificar que el reclamo existe
    const reclamo = await this.prisma.reclamo.findUnique({
      where: { id: reclamoId },
    });

    if (!reclamo) {
      throw new NotFoundException('Reclamo no encontrado');
    }

    // Si es profesional (cliente), no mostrar comentarios internos
    const where: any = { reclamoId };

    if (usuarioRol === Role.PROFESIONAL && !incluirInternos) {
      where.interno = false;
    }

    const comentarios = await this.prisma.comentario.findMany({
      where,
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

    return comentarios.map((comentario) => ({
      id: comentario.id,
      contenido: comentario.contenido,
      interno: comentario.interno,
      usuario: {
        nombre: `${comentario.usuario.nombre} ${comentario.usuario.apellido}`,
        email: comentario.usuario.email,
        rol: comentario.usuario.rol,
      },
      createdAt: comentario.createdAt,
      updatedAt: comentario.updatedAt,
    }));
  }

  async update(
    comentarioId: string,
    usuarioId: string,
    usuarioRol: Role,
    contenido: string,
  ) {
    const comentario = await this.prisma.comentario.findUnique({
      where: { id: comentarioId },
    });

    if (!comentario) {
      throw new NotFoundException('Comentario no encontrado');
    }

    // Solo el autor o un admin puede editar
    if (
      comentario.usuarioId !== usuarioId &&
      usuarioRol !== Role.ADMINISTRADOR
    ) {
      throw new ForbiddenException(
        'No tienes permisos para editar este comentario',
      );
    }

    const comentarioActualizado = await this.prisma.comentario.update({
      where: { id: comentarioId },
      data: { contenido },
      include: {
        usuario: {
          select: {
            nombre: true,
            apellido: true,
            rol: true,
          },
        },
      },
    });

    this.logger.log(`Comentario ${comentarioId} actualizado por usuario ${usuarioId}`);

    return {
      id: comentarioActualizado.id,
      contenido: comentarioActualizado.contenido,
      interno: comentarioActualizado.interno,
      usuario: {
        nombre: `${comentarioActualizado.usuario.nombre} ${comentarioActualizado.usuario.apellido}`,
        rol: comentarioActualizado.usuario.rol,
      },
      createdAt: comentarioActualizado.createdAt,
      updatedAt: comentarioActualizado.updatedAt,
    };
  }

  async delete(comentarioId: string, usuarioId: string, usuarioRol: Role) {
    const comentario = await this.prisma.comentario.findUnique({
      where: { id: comentarioId },
    });

    if (!comentario) {
      throw new NotFoundException('Comentario no encontrado');
    }

    // Solo el autor o un admin puede eliminar
    if (
      comentario.usuarioId !== usuarioId &&
      usuarioRol !== Role.ADMINISTRADOR
    ) {
      throw new ForbiddenException(
        'No tienes permisos para eliminar este comentario',
      );
    }

    await this.prisma.comentario.delete({
      where: { id: comentarioId },
    });

    this.logger.log(`Comentario ${comentarioId} eliminado por usuario ${usuarioId}`);

    return { message: 'Comentario eliminado correctamente' };
  }
}