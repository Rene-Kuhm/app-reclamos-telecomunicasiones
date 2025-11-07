import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
  UnauthorizedException,
  Logger,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateUsuarioDto, UpdateUsuarioDto, UpdatePasswordDto } from './dto';
import * as bcrypt from 'bcrypt';
import { Usuario, Prisma } from '@prisma/client';

// Define Role inline
export enum RolUsuario {
  PROFESIONAL = 'PROFESIONAL',
  TECNICO = 'TECNICO',
  SUPERVISOR = 'SUPERVISOR',
  ADMINISTRADOR = 'ADMINISTRADOR',
}

@Injectable()
export class UsuariosService {
  private readonly logger = new Logger(UsuariosService.name);

  constructor(private prisma: PrismaService) {}

  async create(createUsuarioDto: CreateUsuarioDto): Promise<any> {
    const { email, password, ...rest } = createUsuarioDto;

    // Verificar si el email ya existe
    const existingEmail = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (existingEmail) {
      throw new ConflictException('El email ya está registrado');
    }

    // Hash del password
    const hashedPassword = await bcrypt.hash(password, 12);

    try {
      const usuario = await this.prisma.usuario.create({
        data: {
          email,
          password_hash: hashedPassword,
          nombre: rest.nombre,
          apellido: rest.apellido,
          telefono: rest.telefono,
          rol: rest.rol || 'PROFESIONAL',
          activo: true,
        },
      });

      this.logger.log(`Usuario creado: ${usuario.email}`);

      // Eliminar campos sensibles
      const { password_hash: _, mfa_secret, ...result } = usuario;
      return result;
    } catch (error) {
      this.logger.error('Error al crear usuario', error);
      throw new BadRequestException('Error al crear usuario');
    }
  }

  async findAll(params?: {
    skip?: number;
    take?: number;
    where?: Prisma.UsuarioWhereInput;
    orderBy?: Prisma.UsuarioOrderByWithRelationInput;
  }): Promise<{ data: any[]; total: number }> {
    const { skip = 0, take = 10, where, orderBy } = params || {};

    const [data, total] = await Promise.all([
      this.prisma.usuario.findMany({
        skip,
        take,
        where: {
          ...where,
          deleted_at: null, // Solo usuarios no eliminados
        },
        orderBy: orderBy || { created_at: 'desc' },
        select: {
          id: true,
          email: true,
          nombre: true,
          apellido: true,
          telefono: true,
          rol: true,
          activo: true,
          ultimo_login: true,
          mfa_habilitado: true,
          created_at: true,
          updated_at: true,
        },
      }),
      this.prisma.usuario.count({
        where: {
          ...where,
          deleted_at: null,
        },
      }),
    ]);

    return { data, total };
  }

  async findByFilters(
    rol?: string,
    activo?: boolean,
    search?: string,
    page: number = 1,
    limit: number = 10,
  ): Promise<{ data: any[]; total: number; page: number; pages: number }> {
    const skip = (page - 1) * limit;

    const where: Prisma.UsuarioWhereInput = {
      deleted_at: null,
      ...(rol && { rol }),
      ...(activo !== undefined && { activo }),
      ...(search && {
        OR: [
          { email: { contains: search, mode: 'insensitive' } },
          { nombre: { contains: search, mode: 'insensitive' } },
          { apellido: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    const { data, total } = await this.findAll({
      skip,
      take: limit,
      where,
    });

    return {
      data,
      total,
      page,
      pages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string): Promise<any> {
    const usuario = await this.prisma.usuario.findFirst({
      where: {
        id,
        deleted_at: null,
      },
      include: {
        reclamos_creados: {
          take: 5,
          orderBy: { created_at: 'desc' },
          select: {
            id: true,
            numero_reclamo: true,
            titulo: true,
            estado: true,
            prioridad: true,
            created_at: true,
          },
        },
        reclamos_asignados: {
          take: 5,
          orderBy: { created_at: 'desc' },
          select: {
            id: true,
            numero_reclamo: true,
            titulo: true,
            estado: true,
            prioridad: true,
            created_at: true,
          },
        },
        _count: {
          select: {
            reclamos_creados: true,
            reclamos_asignados: true,
            comentarios: true,
            notificaciones: true,
          },
        },
      },
    });

    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // Eliminar campos sensibles
    const { password_hash, mfa_secret, ...result } = usuario;
    return result;
  }

  async findByEmail(email: string): Promise<Usuario> {
    const usuario = await this.prisma.usuario.findFirst({
      where: {
        email,
        deleted_at: null,
      },
    });

    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    return usuario;
  }

  async update(
    id: string,
    updateUsuarioDto: UpdateUsuarioDto,
    currentUserId: string,
    currentUserRole: string,
  ): Promise<any> {
    // Verificar que el usuario existe
    const usuario = await this.findOne(id);

    // Verificar permisos
    if (currentUserId !== id && currentUserRole !== RolUsuario.ADMINISTRADOR) {
      throw new ForbiddenException(
        'No tienes permisos para actualizar este usuario',
      );
    }

    // Si se está cambiando el rol, solo el admin puede hacerlo
    if (
      updateUsuarioDto.rol &&
      updateUsuarioDto.rol !== usuario.rol &&
      currentUserRole !== RolUsuario.ADMINISTRADOR
    ) {
      throw new ForbiddenException('Solo un administrador puede cambiar roles');
    }

    // Si se está cambiando el estado, solo el admin puede hacerlo
    if (
      updateUsuarioDto.activo !== undefined &&
      updateUsuarioDto.activo !== usuario.activo &&
      currentUserRole !== RolUsuario.ADMINISTRADOR
    ) {
      throw new ForbiddenException(
        'Solo un administrador puede cambiar el estado',
      );
    }

    // Verificar email único si se está cambiando
    if (updateUsuarioDto.email && updateUsuarioDto.email !== usuario.email) {
      const existingEmail = await this.prisma.usuario.findUnique({
        where: { email: updateUsuarioDto.email },
      });

      if (existingEmail) {
        throw new ConflictException('El email ya está en uso');
      }
    }

    try {
      const updatedUsuario = await this.prisma.usuario.update({
        where: { id },
        data: updateUsuarioDto,
      });

      this.logger.log(`Usuario actualizado: ${updatedUsuario.email}`);

      // Eliminar campos sensibles
      const { password_hash, mfa_secret, ...result } = updatedUsuario;
      return result;
    } catch (error) {
      this.logger.error('Error al actualizar usuario', error);
      throw new BadRequestException('Error al actualizar usuario');
    }
  }

  async updatePassword(
    id: string,
    updatePasswordDto: UpdatePasswordDto,
    currentUserId: string,
  ): Promise<{ message: string }> {
    // Solo el propio usuario puede cambiar su contraseña
    if (currentUserId !== id) {
      throw new ForbiddenException(
        'Solo puedes cambiar tu propia contraseña',
      );
    }

    const usuario = await this.prisma.usuario.findUnique({
      where: { id },
    });

    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // Verificar contraseña actual
    const isPasswordValid = await bcrypt.compare(
      updatePasswordDto.currentPassword,
      usuario.password_hash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Contraseña actual incorrecta');
    }

    // Hash de la nueva contraseña
    const hashedPassword = await bcrypt.hash(updatePasswordDto.newPassword, 12);

    await this.prisma.usuario.update({
      where: { id },
      data: {
        password_hash: hashedPassword,
        ultimo_cambio_pass: new Date(),
      },
    });

    this.logger.log(`Contraseña actualizada para usuario: ${usuario.email}`);

    return { message: 'Contraseña actualizada correctamente' };
  }

  async remove(
    id: string,
    currentUserId: string,
    currentUserRole: string,
  ): Promise<{ message: string }> {
    const usuario = await this.findOne(id);

    // Solo admins pueden eliminar usuarios, o el propio usuario
    if (currentUserId !== id && currentUserRole !== RolUsuario.ADMINISTRADOR) {
      throw new ForbiddenException(
        'No tienes permisos para eliminar este usuario',
      );
    }

    // No permitir eliminar al último admin
    if (usuario.rol === RolUsuario.ADMINISTRADOR) {
      const adminCount = await this.prisma.usuario.count({
        where: {
          rol: RolUsuario.ADMINISTRADOR,
          deleted_at: null,
          id: { not: id },
        },
      });

      if (adminCount === 0) {
        throw new BadRequestException(
          'No se puede eliminar el último administrador',
        );
      }
    }

    // Soft delete
    await this.prisma.usuario.update({
      where: { id },
      data: {
        deleted_at: new Date(),
        activo: false,
        // Agregar timestamp al email para permitir reutilización
        email: `${usuario.email}_deleted_${Date.now()}`,
      },
    });

    this.logger.log(`Usuario eliminado (soft delete): ${usuario.email}`);

    return { message: 'Usuario eliminado correctamente' };
  }

  async restore(
    id: string,
    currentUserRole: string,
  ): Promise<any> {
    // Solo admins pueden restaurar usuarios
    if (currentUserRole !== RolUsuario.ADMINISTRADOR) {
      throw new ForbiddenException(
        'Solo administradores pueden restaurar usuarios',
      );
    }

    const usuario = await this.prisma.usuario.findUnique({
      where: { id },
    });

    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    if (!usuario.deleted_at) {
      throw new BadRequestException('El usuario no está eliminado');
    }

    // Restaurar el email original
    const originalEmail = usuario.email.replace(/_deleted_\d+$/, '');

    // Verificar que el email no esté en uso
    const existingEmail = await this.prisma.usuario.findFirst({
      where: {
        email: originalEmail,
        id: { not: id },
      },
    });

    if (existingEmail) {
      throw new ConflictException(
        'No se puede restaurar, el email ya está en uso',
      );
    }

    const restoredUsuario = await this.prisma.usuario.update({
      where: { id },
      data: {
        deleted_at: null,
        email: originalEmail,
        activo: true,
      },
    });

    this.logger.log(`Usuario restaurado: ${originalEmail}`);

    const { password_hash, mfa_secret, ...result } = restoredUsuario;
    return result;
  }

  async getStats(): Promise<any> {
    const [
      totalUsuarios,
      usuariosActivos,
      usuariosInactivos,
      usuariosPorRol,
      usuariosConMfa,
      usuariosNuevosEsteMes,
    ] = await Promise.all([
      this.prisma.usuario.count({ where: { deleted_at: null } }),
      this.prisma.usuario.count({
        where: { activo: true, deleted_at: null },
      }),
      this.prisma.usuario.count({
        where: { activo: false, deleted_at: null },
      }),
      this.prisma.usuario.groupBy({
        by: ['rol'],
        where: { deleted_at: null },
        _count: true,
      }),
      this.prisma.usuario.count({
        where: { mfa_habilitado: true, deleted_at: null },
      }),
      this.prisma.usuario.count({
        where: {
          created_at: {
            gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
          },
          deleted_at: null,
        },
      }),
    ]);

    return {
      totalUsuarios,
      usuariosActivos,
      usuariosInactivos,
      usuariosPorRol: usuariosPorRol.reduce((acc: Record<string, number>, curr: any) => {
        acc[curr.rol] = curr._count;
        return acc;
      }, {} as Record<string, number>),
      usuariosConMfa,
      usuariosNuevosEsteMes,
    };
  }
}