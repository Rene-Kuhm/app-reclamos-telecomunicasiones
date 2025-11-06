import { IsString, IsNotEmpty, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class EnableMfaDto {
  @ApiProperty({
    description: 'Secreto base32 generado',
    example: 'JBSWY3DPEHPK3PXP',
  })
  @IsString()
  @IsNotEmpty()
  secret: string;

  @ApiProperty({
    description: 'Código TOTP de 6 dígitos para verificar',
    example: '123456',
  })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  code: string;
}

export class DisableMfaDto {
  @ApiProperty({
    description: 'Contraseña actual del usuario',
    example: 'MySecurePassword123!',
  })
  @IsString()
  @IsNotEmpty()
  password: string;
}