import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
  UnauthorizedException,
  Logger,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUsuarioDto, UpdateUsuarioDto, UpdatePasswordDto } from './dto';
import * as bcrypt from 'bcrypt';
import { Usuario, Role, EstadoUsuario, Prisma } from '@prisma/client';

@Injectable()
export class UsuariosService {
  private readonly logger = new Logger(UsuariosService.name);

  constructor(private prisma: PrismaService) {}

  async create(createUsuarioDto: CreateUsuarioDto): Promise<Usuario> {
    const { email, password, dni, ...rest } = createUsuarioDto;

    // Verificar si el email ya existe
    const existingEmail = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (existingEmail) {
      throw new ConflictException('El email ya está registrado');
    }

    // Verificar si el DNI ya existe
    if (dni) {
      const existingDni = await this.prisma.usuario.findUnique({
        where: { dni },
      });

      if (existingDni) {
        throw new ConflictException('El DNI ya está registrado');
      }
    }

    // Hash del password
    const hashedPassword = await bcrypt.hash(password, 12);

    try {
      const usuario = await this.prisma.usuario.create({
        data: {
          email,
          password: hashedPassword,
          dni,
          ...rest,
          estado: EstadoUsuario.ACTIVO,
        },
      });

      this.logger.log(`Usuario creado: ${usuario.email}`);

      // Eliminar campos sensibles
      const { password: _, refreshToken: __, mfaSecret: ___, ...result } =
        usuario;
      return result as Usuario;
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
  }): Promise<{ data: Usuario[]; total: number }> {
    const { skip = 0, take = 10, where, orderBy } = params || {};

    const [data, total] = await Promise.all([
      this.prisma.usuario.findMany({
        skip,
        take,
        where: {
          ...where,
          deletedAt: null, // Solo usuarios no eliminados
        },
        orderBy: orderBy || { createdAt: 'desc' },
        select: {
          id: true,
          email: true,
          nombre: true,
          apellido: true,
          telefono: true,
          dni: true,
          direccion: true,
          rol: true,
          estado: true,
          ultimoLogin: true,
          mfaEnabled: true,
          notificacionesEnabled: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
      this.prisma.usuario.count({
        where: {
          ...where,
          deletedAt: null,
        },
      }),
    ]);

    return { data: data as Usuario[], total };
  }

  async findByFilters(
    rol?: Role,
    estado?: EstadoUsuario,
    search?: string,
    page: number = 1,
    limit: number = 10,
  ): Promise<{ data: Usuario[]; total: number; page: number; pages: number }> {
    const skip = (page - 1) * limit;

    const where: Prisma.UsuarioWhereInput = {
      deletedAt: null,
      ...(rol && { rol }),
      ...(estado && { estado }),
      ...(search && {
        OR: [
          { email: { contains: search, mode: 'insensitive' } },
          { nombre: { contains: search, mode: 'insensitive' } },
          { apellido: { contains: search, mode: 'insensitive' } },
          { dni: { contains: search, mode: 'insensitive' } },
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

  async findOne(id: string): Promise<Usuario> {
    const usuario = await this.prisma.usuario.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      include: {
        reclamosCreados: {
          take: 5,
          orderBy: { createdAt: 'desc' },
          select: {
            id: true,
            codigo: true,
            titulo: true,
            estado: true,
            prioridad: true,
            createdAt: true,
          },
        },
        reclamosAsignados: {
          take: 5,
          orderBy: { createdAt: 'desc' },
          select: {
            id: true,
            codigo: true,
            titulo: true,
            estado: true,
            prioridad: true,
            createdAt: true,
          },
        },
        _count: {
          select: {
            reclamosCreados: true,
            reclamosAsignados: true,
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
    const { password, refreshToken, mfaSecret, ...result } = usuario;
    return result as Usuario;
  }

  async findByEmail(email: string): Promise<Usuario> {
    const usuario = await this.prisma.usuario.findFirst({
      where: {
        email,
        deletedAt: null,
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
    currentUserRole: Role,
  ): Promise<Usuario> {
    // Verificar que el usuario existe
    const usuario = await this.findOne(id);

    // Verificar permisos
    if (currentUserId !== id && currentUserRole !== Role.ADMINISTRADOR) {
      throw new ForbiddenException(
        'No tienes permisos para actualizar este usuario',
      );
    }

    // Si se está cambiando el rol, solo el admin puede hacerlo
    if (
      updateUsuarioDto.rol &&
      updateUsuarioDto.rol !== usuario.rol &&
      currentUserRole !== Role.ADMINISTRADOR
    ) {
      throw new ForbiddenException('Solo un administrador puede cambiar roles');
    }

    // Si se está cambiando el estado, solo el admin puede hacerlo
    if (
      updateUsuarioDto.estado &&
      updateUsuarioDto.estado !== usuario.estado &&
      currentUserRole !== Role.ADMINISTRADOR
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

    // Verificar DNI único si se está cambiando
    if (updateUsuarioDto.dni && updateUsuarioDto.dni !== usuario.dni) {
      const existingDni = await this.prisma.usuario.findUnique({
        where: { dni: updateUsuarioDto.dni },
      });

      if (existingDni) {
        throw new ConflictException('El DNI ya está en uso');
      }
    }

    try {
      const updatedUsuario = await this.prisma.usuario.update({
        where: { id },
        data: updateUsuarioDto,
      });

      this.logger.log(`Usuario actualizado: ${updatedUsuario.email}`);

      // Eliminar campos sensibles
      const { password, refreshToken, mfaSecret, ...result } = updatedUsuario;
      return result as Usuario;
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
      usuario.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Contraseña actual incorrecta');
    }

    // Hash de la nueva contraseña
    const hashedPassword = await bcrypt.hash(updatePasswordDto.newPassword, 12);

    await this.prisma.usuario.update({
      where: { id },
      data: {
        password: hashedPassword,
        // Invalidar refresh tokens al cambiar contraseña
        refreshToken: null,
      },
    });

    this.logger.log(`Contraseña actualizada para usuario: ${usuario.email}`);

    return { message: 'Contraseña actualizada correctamente' };
  }

  async remove(
    id: string,
    currentUserId: string,
    currentUserRole: Role,
  ): Promise<{ message: string }> {
    const usuario = await this.findOne(id);

    // Solo admins pueden eliminar usuarios, o el propio usuario
    if (currentUserId !== id && currentUserRole !== Role.ADMINISTRADOR) {
      throw new ForbiddenException(
        'No tienes permisos para eliminar este usuario',
      );
    }

    // No permitir eliminar al último admin
    if (usuario.rol === Role.ADMINISTRADOR) {
      const adminCount = await this.prisma.usuario.count({
        where: {
          rol: Role.ADMINISTRADOR,
          deletedAt: null,
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
        deletedAt: new Date(),
        estado: EstadoUsuario.INACTIVO,
        // Agregar timestamp al email para permitir reutilización
        email: `${usuario.email}_deleted_${Date.now()}`,
      },
    });

    this.logger.log(`Usuario eliminado (soft delete): ${usuario.email}`);

    return { message: 'Usuario eliminado correctamente' };
  }

  async restore(
    id: string,
    currentUserRole: Role,
  ): Promise<Usuario> {
    // Solo admins pueden restaurar usuarios
    if (currentUserRole !== Role.ADMINISTRADOR) {
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

    if (!usuario.deletedAt) {
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
        deletedAt: null,
        email: originalEmail,
        estado: EstadoUsuario.ACTIVO,
      },
    });

    this.logger.log(`Usuario restaurado: ${originalEmail}`);

    const { password, refreshToken, mfaSecret, ...result } = restoredUsuario;
    return result as Usuario;
  }

  async getStats(): Promise<any> {
    const [
      totalUsuarios,
      usuariosActivos,
      usuariosSuspendidos,
      usuariosPorRol,
      usuariosConMfa,
      usuariosNuevosEsteMes,
    ] = await Promise.all([
      this.prisma.usuario.count({ where: { deletedAt: null } }),
      this.prisma.usuario.count({
        where: { estado: EstadoUsuario.ACTIVO, deletedAt: null },
      }),
      this.prisma.usuario.count({
        where: { estado: EstadoUsuario.SUSPENDIDO, deletedAt: null },
      }),
      this.prisma.usuario.groupBy({
        by: ['rol'],
        where: { deletedAt: null },
        _count: true,
      }),
      this.prisma.usuario.count({
        where: { mfaEnabled: true, deletedAt: null },
      }),
      this.prisma.usuario.count({
        where: {
          createdAt: {
            gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
          },
          deletedAt: null,
        },
      }),
    ]);

    return {
      totalUsuarios,
      usuariosActivos,
      usuariosSuspendidos,
      usuariosPorRol: usuariosPorRol.reduce((acc, curr) => {
        acc[curr.rol] = curr._count;
        return acc;
      }, {}),
      usuariosConMfa,
      usuariosNuevosEsteMes,
    };
  }
}