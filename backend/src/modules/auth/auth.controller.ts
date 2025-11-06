import {
  Controller,
  Post,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  Get,
  Delete,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RefreshTokenGuard } from './guards/refresh-token.guard';
import { Public } from '../../common/decorators/public.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { RequestWithUser } from '../../common/types/request-with-user.type';
import {
  RegisterDto,
  LoginDto,
  ForgotPasswordDto,
  ResetPasswordDto,
  VerifyMfaDto,
  EnableMfaDto,
  DisableMfaDto,
} from './dto';
import { Usuario } from '@prisma/client';

@ApiTags('Autenticación')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Registrar nuevo usuario' })
  @ApiResponse({
    status: 201,
    description: 'Usuario registrado correctamente',
  })
  @ApiResponse({ status: 409, description: 'Email o DNI ya registrado' })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Public()
  @UseGuards(LocalAuthGuard)
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Iniciar sesión' })
  @ApiBody({ type: LoginDto })
  @ApiResponse({
    status: 200,
    description: 'Sesión iniciada correctamente',
  })
  @ApiResponse({ status: 401, description: 'Credenciales inválidas' })
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Public()
  @Post('mfa/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verificar código MFA' })
  @ApiResponse({
    status: 200,
    description: 'MFA verificado correctamente',
  })
  @ApiResponse({ status: 401, description: 'Código MFA inválido' })
  async verifyMfa(@Body() verifyMfaDto: VerifyMfaDto) {
    return this.authService.verifyMfa(verifyMfaDto);
  }

  @UseGuards(JwtAuthGuard)
  @Post('mfa/enable')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Habilitar autenticación de dos factores' })
  @ApiResponse({
    status: 200,
    description: 'QR code generado para MFA',
  })
  async enableMfa(@CurrentUser() user: Usuario) {
    return this.authService.enableMfa(user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post('mfa/confirm')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Confirmar activación de MFA' })
  @ApiResponse({
    status: 200,
    description: 'MFA activado correctamente',
  })
  async confirmMfa(
    @CurrentUser() user: Usuario,
    @Body() enableMfaDto: EnableMfaDto,
  ) {
    return this.authService.confirmMfa(user.id, enableMfaDto);
  }

  @UseGuards(JwtAuthGuard)
  @Post('mfa/disable')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Desactivar autenticación de dos factores' })
  @ApiResponse({
    status: 200,
    description: 'MFA desactivado correctamente',
  })
  async disableMfa(
    @CurrentUser() user: Usuario,
    @Body() disableMfaDto: DisableMfaDto,
  ) {
    return this.authService.disableMfa(user.id, disableMfaDto.password);
  }

  @UseGuards(JwtAuthGuard)
  @Delete('logout')
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Cerrar sesión' })
  @ApiResponse({
    status: 200,
    description: 'Sesión cerrada correctamente',
  })
  async logout(@CurrentUser() user: Usuario) {
    return this.authService.logout(user.id);
  }

  @Public()
  @UseGuards(RefreshTokenGuard)
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Refrescar tokens' })
  @ApiResponse({
    status: 200,
    description: 'Tokens actualizados correctamente',
  })
  async refreshTokens(@Request() req: RequestWithUser) {
    const userId = req.user['sub'];
    const refreshToken = req.user['refreshToken'];
    return this.authService.refreshTokens(userId, refreshToken);
  }

  @Public()
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Solicitar restablecimiento de contraseña' })
  @ApiResponse({
    status: 200,
    description: 'Email de recuperación enviado',
  })
  async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordDto) {
    return this.authService.forgotPassword(forgotPasswordDto);
  }

  @Public()
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Restablecer contraseña' })
  @ApiResponse({
    status: 200,
    description: 'Contraseña actualizada correctamente',
  })
  @ApiResponse({ status: 400, description: 'Token inválido o expirado' })
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.resetPassword(resetPasswordDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener usuario actual' })
  @ApiResponse({
    status: 200,
    description: 'Datos del usuario actual',
  })
  async getCurrentUser(@CurrentUser() user: Usuario) {
    const { password, refreshToken, mfaSecret, ...userWithoutSensitive } =
      user;
    return userWithoutSensitive;
  }
}