import { IsUUID, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class AsignarReclamoDto {
  @ApiProperty({
    description: 'UUID del técnico a asignar',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsUUID('4', { message: 'ID de técnico inválido' })
  tecnicoId: string;

  @ApiPropertyOptional({
    description: 'Notas adicionales para el técnico',
    example: 'Llamar al cliente antes de visitar',
  })
  @IsOptional()
  @IsString()
  notas?: string;
}

export class CerrarReclamoDto {
  @ApiProperty({
    description: 'Descripción de la solución aplicada',
    example: 'Se reemplazó el modem defectuoso y se verificó la conexión',
  })
  @IsString()
  solucion: string;

  @ApiPropertyOptional({
    description: 'Notas finales del cierre',
  })
  @IsOptional()
  @IsString()
  notasFinales?: string;
}

export class RechazarReclamoDto {
  @ApiProperty({
    description: 'Motivo del rechazo',
    example: 'El problema reportado no está cubierto por el servicio',
  })
  @IsString()
  motivoRechazo: string;
}