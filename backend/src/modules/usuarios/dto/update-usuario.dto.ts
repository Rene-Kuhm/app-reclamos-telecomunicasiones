import {
  IsEmail,
  IsString,
  IsOptional,
  IsEnum,
  MaxLength,
  IsBoolean,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Role, EstadoUsuario } from '@prisma/client';

export class UpdateUsuarioDto {
  @ApiPropertyOptional({
    description: 'Email del usuario',
    example: 'usuario@example.com',
  })
  @IsOptional()
  @IsEmail({}, { message: 'Email inválido' })
  email?: string;

  @ApiPropertyOptional({
    description: 'Nombre del usuario',
    example: 'Juan',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  nombre?: string;

  @ApiPropertyOptional({
    description: 'Apellido del usuario',
    example: 'Pérez',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  apellido?: string;

  @ApiPropertyOptional({
    description: 'Teléfono del usuario',
    example: '+595981234567',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  telefono?: string;

  @ApiPropertyOptional({
    description: 'DNI del usuario',
    example: '12345678',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  dni?: string;

  @ApiPropertyOptional({
    description: 'Dirección del usuario',
    example: 'Av. Principal 123',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  direccion?: string;

  @ApiPropertyOptional({
    description: 'Rol del usuario',
    enum: Role,
    example: Role.PROFESIONAL,
  })
  @IsOptional()
  @IsEnum(Role, { message: 'Rol inválido' })
  rol?: Role;

  @ApiPropertyOptional({
    description: 'Estado del usuario',
    enum: EstadoUsuario,
    example: EstadoUsuario.ACTIVO,
  })
  @IsOptional()
  @IsEnum(EstadoUsuario, { message: 'Estado inválido' })
  estado?: EstadoUsuario;

  @ApiPropertyOptional({
    description: 'Notificaciones habilitadas',
    example: true,
  })
  @IsOptional()
  @IsBoolean()
  notificacionesEnabled?: boolean;
}

export class UpdatePasswordDto {
  @ApiPropertyOptional({
    description: 'Contraseña actual',
    example: 'OldPassword123!',
  })
  @IsString()
  currentPassword: string;

  @ApiPropertyOptional({
    description: 'Nueva contraseña',
    example: 'NewPassword123!',
  })
  @IsString()
  newPassword: string;
}