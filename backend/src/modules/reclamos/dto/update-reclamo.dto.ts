import {
  IsString,
  IsOptional,
  IsEnum,
  MaxLength,
  IsLatitude,
  IsLongitude,
  IsObject,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { TipoReclamo, PrioridadReclamo, TipoServicio } from '@prisma/client';

export class UpdateReclamoDto {
  @ApiPropertyOptional({
    description: 'Título del reclamo',
    example: 'Internet sin conexión',
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  titulo?: string;

  @ApiPropertyOptional({
    description: 'Descripción detallada del problema',
  })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional({
    description: 'Tipo de reclamo',
    enum: TipoReclamo,
  })
  @IsOptional()
  @IsEnum(TipoReclamo)
  tipo?: TipoReclamo;

  @ApiPropertyOptional({
    description: 'Tipo de servicio afectado',
    enum: TipoServicio,
  })
  @IsOptional()
  @IsEnum(TipoServicio)
  tipoServicio?: TipoServicio;

  @ApiPropertyOptional({
    description: 'Prioridad del reclamo',
    enum: PrioridadReclamo,
  })
  @IsOptional()
  @IsEnum(PrioridadReclamo)
  prioridad?: PrioridadReclamo;

  @ApiPropertyOptional({
    description: 'Dirección del problema',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  direccion?: string;

  @ApiPropertyOptional({
    description: 'Latitud de la ubicación',
  })
  @IsOptional()
  @IsLatitude()
  latitud?: number;

  @ApiPropertyOptional({
    description: 'Longitud de la ubicación',
  })
  @IsOptional()
  @IsLongitude()
  longitud?: number;

  @ApiPropertyOptional({
    description: 'Información adicional del contacto',
  })
  @IsOptional()
  @IsObject()
  infoContacto?: Record<string, any>;
}