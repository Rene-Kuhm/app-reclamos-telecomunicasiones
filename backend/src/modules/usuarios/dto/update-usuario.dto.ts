import {
  IsEmail,
  IsString,
  IsOptional,
  IsEnum,
  MaxLength,
  IsBoolean,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { RolUsuario } from './create-usuario.dto';

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
    description: 'Rol del usuario',
    enum: RolUsuario,
    example: RolUsuario.PROFESIONAL,
  })
  @IsOptional()
  @IsEnum(RolUsuario, { message: 'Rol inválido' })
  rol?: string;

  @ApiPropertyOptional({
    description: 'Usuario activo',
    example: true,
  })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
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