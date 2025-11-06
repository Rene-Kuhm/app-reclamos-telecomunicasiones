import { IsString, IsNotEmpty, IsBoolean, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateComentarioDto {
  @ApiProperty({
    description: 'Contenido del comentario',
    example: 'El cliente confirmó que el problema persiste',
  })
  @IsString()
  @IsNotEmpty({ message: 'El contenido del comentario es requerido' })
  contenido: string;

  @ApiPropertyOptional({
    description: 'Si es un comentario interno (no visible para el cliente)',
    example: false,
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  interno?: boolean;
}