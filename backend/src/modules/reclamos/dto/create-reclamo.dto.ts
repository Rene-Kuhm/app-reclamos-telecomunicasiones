import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsOptional,
  MaxLength,
  IsLatitude,
  IsLongitude,
  IsObject,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PrioridadReclamo, CategoriaReclamo } from '../../../common/types/prisma-enums';

export class CreateReclamoDto {
  @ApiProperty({
    description: 'Título del reclamo',
    example: 'Internet sin conexión',
    maxLength: 200,
  })
  @IsString()
  @IsNotEmpty({ message: 'El título es requerido' })
  @MaxLength(200)
  titulo: string;

  @ApiProperty({
    description: 'Descripción detallada del problema',
    example:
      'Desde hace 2 días no tengo conexión a internet. El modem parpadea en rojo.',
  })
  @IsString()
  @IsNotEmpty({ message: 'La descripción es requerida' })
  descripcion: string;

  @ApiProperty({
    description: 'Categoría del reclamo',
    enum: CategoriaReclamo,
    example: CategoriaReclamo.INTERNET_FIBRA,
  })
  @IsEnum(CategoriaReclamo, { message: 'Categoría de reclamo inválida' })
  @IsNotEmpty()
  categoria: string;

  @ApiPropertyOptional({
    description: 'Subcategoría del reclamo (opcional)',
    example: 'Sin señal',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  subcategoria?: string;

  @ApiPropertyOptional({
    description: 'Prioridad del reclamo (asignada automáticamente si no se especifica)',
    enum: PrioridadReclamo,
    example: PrioridadReclamo.MEDIA,
  })
  @IsOptional()
  @IsEnum(PrioridadReclamo, { message: 'Prioridad inválida' })
  prioridad?: string;

  @ApiPropertyOptional({
    description: 'Dirección del problema',
    example: 'Av. España 1234, Asunción',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  direccion?: string;

  @ApiPropertyOptional({
    description: 'Latitud de la ubicación',
    example: -25.2637,
  })
  @IsOptional()
  @IsLatitude()
  latitud?: number;

  @ApiPropertyOptional({
    description: 'Longitud de la ubicación',
    example: -57.5759,
  })
  @IsOptional()
  @IsLongitude()
  longitud?: number;

  @ApiPropertyOptional({
    description: 'Información adicional del contacto en formato JSON',
    example: {
      telefonoAlternativo: '+595981234567',
      horariosDisponibles: 'Lunes a Viernes 8-17hs',
    },
  })
  @IsOptional()
  @IsObject()
  infoContacto?: Record<string, any>;
}