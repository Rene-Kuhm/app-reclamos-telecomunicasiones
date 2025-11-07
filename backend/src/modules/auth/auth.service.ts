import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  ConflictException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import * as speakeasy from 'speakeasy';
import * as QRCode from 'qrcode';
import { EstadoUsuario } from '../../common/types/prisma-enums';
import { Usuario } from '@prisma/client';
import {
  RegisterDto,
  LoginDto,
  ForgotPasswordDto,
  ResetPasswordDto,
  VerifyMfaDto,
  EnableMfaDto,
} from './dto';
import { randomBytes } from 'crypto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (!user) {
      return null;
    }

    if (!user.activo) {
      throw new UnauthorizedException('Usuario inactivo o suspendido');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      // Incrementar intentos fallidos
      await this.prisma.usuario.update({
        where: { id: user.id },
        data: {
          intentos_fallidos: user.intentos_fallidos + 1,
          bloqueado_hasta: user.intentos_fallidos + 1 >= 5 ? new Date(Date.now() + 3600000) : null,
          activo: user.intentos_fallidos + 1 >= 5 ? false : user.activo,
        },
      });

      if (user.intentos_fallidos + 1 >= 5) {
        throw new UnauthorizedException(
          'Cuenta suspendida por múltiples intentos fallidos',
        );
      }

      return null;
    }

    // Resetear intentos fallidos en login exitoso
    if (user.intentos_fallidos > 0) {
      await this.prisma.usuario.update({
        where: { id: user.id },
        data: {
          intentos_fallidos: 0,
          bloqueado_hasta: null,
        },
      });
    }

    const { password_hash: _, ...result } = user;
    return result;
  }

  async register(registerDto: RegisterDto) {
    const { email, password, nombre, apellido, telefono, rol } = registerDto;

    // Verificar si el email ya existe
    const existingUser = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('El email ya está registrado');
    }

    // Hash del password
    const hashedPassword = await bcrypt.hash(password, 12);

    try {
      const user = await this.prisma.usuario.create({
        data: {
          email,
          password_hash: hashedPassword,
          nombre,
          apellido,
          telefono,
          rol: rol || 'PROFESIONAL',
          activo: true,
        },
        select: {
          id: true,
          email: true,
          nombre: true,
          apellido: true,
          rol: true,
          activo: true,
          created_at: true,
        },
      });

      this.logger.log(`Nuevo usuario registrado: ${email}`);

      const tokens = await this.getTokens(user);

      await this.updateRefreshToken(user.id, tokens.refreshToken);

      return {
        user,
        ...tokens,
      };
    } catch (error) {
      this.logger.error('Error al registrar usuario', error);
      throw new BadRequestException('Error al registrar usuario');
    }
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.password);

    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Verificar si requiere MFA
    if (user.mfa_habilitado && user.mfa_secret) {
      return {
        requiresMfa: true,
        tempToken: await this.generateTempToken(user),
      };
    }

    // Actualizar último login
    await this.prisma.usuario.update({
      where: { id: user.id },
      data: { ultimo_login: new Date() },
    });

    const tokens = await this.getTokens(user);
    await this.updateRefreshToken(user.id, tokens.refreshToken);

    this.logger.log(`Usuario autenticado: ${user.email}`);

    return {
      user,
      ...tokens,
    };
  }

  async verifyMfa(verifyMfaDto: VerifyMfaDto) {
    const { tempToken, code } = verifyMfaDto;

    // Verificar el token temporal
    const payload = this.jwtService.verify(tempToken, {
      secret: this.configService.get<string>('JWT_SECRET'),
    });

    const user = await this.prisma.usuario.findUnique({
      where: { id: payload.sub },
    });

    if (!user || !user.mfa_secret) {
      throw new UnauthorizedException('MFA no configurado');
    }

    // Verificar el código TOTP
    const verified = speakeasy.totp.verify({
      secret: user.mfa_secret,
      encoding: 'base32',
      token: code,
      window: 1,
    });

    if (!verified) {
      throw new UnauthorizedException('Código MFA inválido');
    }

    // Actualizar último login
    await this.prisma.usuario.update({
      where: { id: user.id },
      data: { ultimo_login: new Date() },
    });

    const tokens = await this.getTokens(user);
    await this.updateRefreshToken(user.id, tokens.refreshToken);

    this.logger.log(`Usuario autenticado con MFA: ${user.email}`);

    return {
      user,
      ...tokens,
    };
  }

  async enableMfa(userId: string) {
    const user = await this.prisma.usuario.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // Generar secreto para TOTP
    const secret = speakeasy.generateSecret({
      name: `Reclamos Telecom (${user.email})`,
      length: 32,
    });

    // Guardar secreto temporalmente (no activar hasta verificar)
    const tempSecret = secret.base32;

    // Generar QR code
    const qrCodeUrl = secret.otpauth_url ? await QRCode.toDataURL(secret.otpauth_url) : '';

    return {
      secret: tempSecret,
      qrCode: qrCodeUrl,
    };
  }

  async confirmMfa(userId: string, enableMfaDto: EnableMfaDto) {
    const { secret, code } = enableMfaDto;

    const user = await this.prisma.usuario.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // Verificar el código con el secreto proporcionado
    const verified = speakeasy.totp.verify({
      secret,
      encoding: 'base32',
      token: code,
      window: 1,
    });

    if (!verified) {
      throw new BadRequestException('Código MFA inválido');
    }

    // Activar MFA y guardar el secreto
    await this.prisma.usuario.update({
      where: { id: userId },
      data: {
        mfa_habilitado: true,
        mfa_secret: secret,
      },
    });

    this.logger.log(`MFA activado para usuario: ${user.email}`);

    return {
      message: 'MFA activado correctamente',
    };
  }

  async disableMfa(userId: string, password: string) {
    const user = await this.prisma.usuario.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // Verificar password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Contraseña incorrecta');
    }

    // Desactivar MFA
    await this.prisma.usuario.update({
      where: { id: userId },
      data: {
        mfa_habilitado: false,
        mfa_secret: null,
      },
    });

    this.logger.log(`MFA desactivado para usuario: ${user.email}`);

    return {
      message: 'MFA desactivado correctamente',
    };
  }

  async logout(userId: string) {
    // Revocar todos los refresh tokens del usuario
    await this.prisma.refreshToken.updateMany({
      where: { usuario_id: userId },
      data: { revocado: true },
    });

    this.logger.log(`Usuario cerró sesión: ${userId}`);

    return {
      message: 'Sesión cerrada correctamente',
    };
  }

  async refreshTokens(userId: string, refreshToken: string) {
    const user = await this.prisma.usuario.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('Acceso denegado');
    }

    // Verificar refresh token en la tabla de refresh tokens
    const storedToken = await this.prisma.refreshToken.findFirst({
      where: {
        usuario_id: userId,
        revocado: false,
        expires_at: { gt: new Date() },
      },
    });

    if (!storedToken) {
      throw new UnauthorizedException('Refresh token inválido o expirado');
    }

    const tokens = await this.getTokens(user);
    await this.updateRefreshToken(user.id, tokens.refreshToken);

    return tokens;
  }

  async forgotPassword(forgotPasswordDto: ForgotPasswordDto) {
    const { email } = forgotPasswordDto;

    const user = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (!user) {
      // No revelar si el email existe o no
      return {
        message:
          'Si el email existe, recibirás instrucciones para restablecer tu contraseña',
      };
    }

    // TODO: Implement reset password token storage (needs separate table or field in schema)
    // For now, just log it
    const resetToken = randomBytes(32).toString('hex');
    this.logger.log(`Password reset requested for: ${email}`);

    return {
      message:
        'Si el email existe, recibirás instrucciones para restablecer tu contraseña',
    };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto) {
    const { token, newPassword } = resetPasswordDto;

    // TODO: Implement token verification with proper storage
    // For now, throw error as feature is not implemented
    throw new BadRequestException('Reset password feature not fully implemented yet');

    // Placeholder for future implementation
    const user = null as any;

    // Hash de la nueva contraseña
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    // Actualizar contraseña y limpiar tokens
    await this.prisma.usuario.update({
      where: { id: user.id },
      data: {
        password_hash: hashedPassword,
        intentos_fallidos: 0,
        bloqueado_hasta: null,
        activo: true,
      },
    });

    this.logger.log(`Contraseña restablecida para: ${user.email}`);

    return {
      message: 'Contraseña actualizada correctamente',
    };
  }

  // Métodos auxiliares privados
  private async getTokens(user: Partial<Usuario>) {
    const payload = {
      sub: user.id,
      email: user.email,
      roles: [user.rol],
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: '15m',
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: '7d',
      }),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }

  private async updateRefreshToken(userId: string, refreshToken: string) {
    // Revocar tokens anteriores
    await this.prisma.refreshToken.updateMany({
      where: { usuario_id: userId },
      data: { revocado: true },
    });

    // Crear nuevo refresh token
    await this.prisma.refreshToken.create({
      data: {
        token: refreshToken,
        usuario_id: userId,
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 días
      },
    });
  }

  private async generateTempToken(user: Partial<Usuario>) {
    const payload = {
      sub: user.id,
      email: user.email,
      temp: true,
    };

    return this.jwtService.signAsync(payload, {
      secret: this.configService.get<string>('JWT_SECRET'),
      expiresIn: '5m',
    });
  }
}