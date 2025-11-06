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
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import * as speakeasy from 'speakeasy';
import * as QRCode from 'qrcode';
import { Usuario, EstadoUsuario } from '@prisma/client';
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

    if (user.estado !== EstadoUsuario.ACTIVO) {
      throw new UnauthorizedException('Usuario inactivo o suspendido');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      // Incrementar intentos fallidos
      await this.prisma.usuario.update({
        where: { id: user.id },
        data: {
          intentosFallidos: user.intentosFallidos + 1,
          ultimoIntentoFallido: new Date(),
          estado:
            user.intentosFallidos + 1 >= 5
              ? EstadoUsuario.SUSPENDIDO
              : user.estado,
        },
      });

      if (user.intentosFallidos + 1 >= 5) {
        throw new UnauthorizedException(
          'Cuenta suspendida por múltiples intentos fallidos',
        );
      }

      return null;
    }

    // Resetear intentos fallidos en login exitoso
    if (user.intentosFallidos > 0) {
      await this.prisma.usuario.update({
        where: { id: user.id },
        data: {
          intentosFallidos: 0,
          ultimoIntentoFallido: null,
        },
      });
    }

    const { password: _, ...result } = user;
    return result;
  }

  async register(registerDto: RegisterDto) {
    const { email, password, nombre, apellido, telefono, rol, dni } = registerDto;

    // Verificar si el email ya existe
    const existingUser = await this.prisma.usuario.findUnique({
      where: { email },
    });

    if (existingUser) {
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
      const user = await this.prisma.usuario.create({
        data: {
          email,
          password: hashedPassword,
          nombre,
          apellido,
          telefono,
          dni,
          rol: rol || 'PROFESIONAL',
          estado: EstadoUsuario.ACTIVO,
        },
        select: {
          id: true,
          email: true,
          nombre: true,
          apellido: true,
          rol: true,
          estado: true,
          createdAt: true,
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
    if (user.mfaEnabled && user.mfaSecret) {
      return {
        requiresMfa: true,
        tempToken: await this.generateTempToken(user),
      };
    }

    // Actualizar último login
    await this.prisma.usuario.update({
      where: { id: user.id },
      data: { ultimoLogin: new Date() },
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

    if (!user || !user.mfaSecret) {
      throw new UnauthorizedException('MFA no configurado');
    }

    // Verificar el código TOTP
    const verified = speakeasy.totp.verify({
      secret: user.mfaSecret,
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
      data: { ultimoLogin: new Date() },
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
    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

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
        mfaEnabled: true,
        mfaSecret: secret,
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
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Contraseña incorrecta');
    }

    // Desactivar MFA
    await this.prisma.usuario.update({
      where: { id: userId },
      data: {
        mfaEnabled: false,
        mfaSecret: null,
      },
    });

    this.logger.log(`MFA desactivado para usuario: ${user.email}`);

    return {
      message: 'MFA desactivado correctamente',
    };
  }

  async logout(userId: string) {
    await this.prisma.usuario.update({
      where: { id: userId },
      data: { refreshToken: null },
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

    if (!user || !user.refreshToken) {
      throw new UnauthorizedException('Acceso denegado');
    }

    const refreshTokenMatches = await bcrypt.compare(
      refreshToken,
      user.refreshToken,
    );

    if (!refreshTokenMatches) {
      throw new UnauthorizedException('Refresh token inválido');
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

    // Generar token de reset
    const resetToken = randomBytes(32).toString('hex');
    const resetTokenExpiry = new Date(Date.now() + 3600000); // 1 hora

    await this.prisma.usuario.update({
      where: { id: user.id },
      data: {
        resetPasswordToken: resetToken,
        resetPasswordExpires: resetTokenExpiry,
      },
    });

    // TODO: Enviar email con el token
    this.logger.log(`Token de reset generado para: ${email}`);

    // En desarrollo, devolver el token (eliminar en producción)
    if (this.configService.get('NODE_ENV') !== 'production') {
      return {
        message: 'Token de reset generado',
        resetToken, // Solo en desarrollo
      };
    }

    return {
      message:
        'Si el email existe, recibirás instrucciones para restablecer tu contraseña',
    };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto) {
    const { token, newPassword } = resetPasswordDto;

    const user = await this.prisma.usuario.findFirst({
      where: {
        resetPasswordToken: token,
        resetPasswordExpires: {
          gt: new Date(),
        },
      },
    });

    if (!user) {
      throw new BadRequestException('Token inválido o expirado');
    }

    // Hash de la nueva contraseña
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    // Actualizar contraseña y limpiar tokens
    await this.prisma.usuario.update({
      where: { id: user.id },
      data: {
        password: hashedPassword,
        resetPasswordToken: null,
        resetPasswordExpires: null,
        refreshToken: null, // Invalidar sesiones existentes
        intentosFallidos: 0,
        ultimoIntentoFallido: null,
        estado:
          user.estado === EstadoUsuario.SUSPENDIDO
            ? EstadoUsuario.ACTIVO
            : user.estado,
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
    const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);

    await this.prisma.usuario.update({
      where: { id: userId },
      data: {
        refreshToken: hashedRefreshToken,
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