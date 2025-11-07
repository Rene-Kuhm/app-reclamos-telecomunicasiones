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
import { CategoriaReclamo, PrioridadReclamo } from '../../../common/types/prisma-enums';

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
    description: 'Categoría del reclamo',
    enum: CategoriaReclamo,
  })
  @IsOptional()
  @IsEnum(CategoriaReclamo)
  categoria?: CategoriaReclamo;

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