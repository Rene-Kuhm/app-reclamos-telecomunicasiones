import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import { NotificacionesService } from './notificaciones.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Usuario } from '@prisma/client';

@ApiTags('Notificaciones')
@Controller('notificaciones')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificacionesController {
  constructor(
    private readonly notificacionesService: NotificacionesService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Obtener notificaciones del usuario actual' })
  @ApiQuery({
    name: 'page',
    required: false,
    description: 'Número de página',
    example: 1,
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    description: 'Elementos por página',
    example: 20,
  })
  @ApiQuery({
    name: 'soloNoLeidas',
    required: false,
    type: Boolean,
    description: 'Solo mostrar notificaciones no leídas',
  })
  @ApiResponse({ status: 200, description: 'Lista de notificaciones' })
  async obtenerNotificaciones(
    @CurrentUser() user: Usuario,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('soloNoLeidas') soloNoLeidas?: string,
  ) {
    const pageNum = page ? parseInt(page) : 1;
    const limitNum = limit ? parseInt(limit) : 20;
    const skip = (pageNum - 1) * limitNum;

    return this.notificacionesService.obtenerNotificaciones(user.id, {
      skip,
      take: limitNum,
      soloNoLeidas: soloNoLeidas === 'true',
    });
  }

  @Patch(':id/leer')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Marcar notificación como leída' })
  @ApiParam({ name: 'id', description: 'UUID de la notificación' })
  @ApiResponse({
    status: 200,
    description: 'Notificación marcada como leída',
  })
  async marcarComoLeida(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.notificacionesService.marcarComoLeida(id, user.id);
  }

  @Patch('leer-todas')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Marcar todas las notificaciones como leídas' })
  @ApiResponse({
    status: 200,
    description: 'Todas las notificaciones marcadas como leídas',
  })
  async marcarTodasComoLeidas(@CurrentUser() user: Usuario) {
    return this.notificacionesService.marcarTodasComoLeidas(user.id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Eliminar notificación' })
  @ApiParam({ name: 'id', description: 'UUID de la notificación' })
  @ApiResponse({ status: 200, description: 'Notificación eliminada' })
  async eliminar(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.notificacionesService.eliminar(id, user.id);
  }

  @Get('preferencias')
  @ApiOperation({ summary: 'Obtener preferencias de notificación' })
  @ApiResponse({
    status: 200,
    description: 'Preferencias de notificación del usuario',
  })
  async obtenerPreferencias(@CurrentUser() user: Usuario) {
    return this.notificacionesService.obtenerPreferencias(user.id);
  }

  @Patch('preferencias')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Actualizar preferencias de notificación' })
  @ApiResponse({
    status: 200,
    description: 'Preferencias actualizadas correctamente',
  })
  async actualizarPreferencias(
    @CurrentUser() user: Usuario,
    @Body() preferencias: any,
  ) {
    return this.notificacionesService.actualizarPreferencias(
      user.id,
      preferencias,
    );
  }
}