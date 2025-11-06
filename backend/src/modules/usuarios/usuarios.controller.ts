import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
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
import { UsuariosService } from './usuarios.service';
import { CreateUsuarioDto, UpdateUsuarioDto, UpdatePasswordDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Usuario, Role, EstadoUsuario } from '@prisma/client';

@ApiTags('Usuarios')
@Controller('usuarios')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  @Post()
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR)
  @ApiOperation({ summary: 'Crear nuevo usuario' })
  @ApiResponse({ status: 201, description: 'Usuario creado correctamente' })
  @ApiResponse({ status: 409, description: 'Email o DNI ya existe' })
  async create(@Body() createUsuarioDto: CreateUsuarioDto) {
    return this.usuariosService.create(createUsuarioDto);
  }

  @Get()
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR)
  @ApiOperation({ summary: 'Obtener todos los usuarios' })
  @ApiQuery({
    name: 'rol',
    required: false,
    enum: Role,
    description: 'Filtrar por rol',
  })
  @ApiQuery({
    name: 'estado',
    required: false,
    enum: EstadoUsuario,
    description: 'Filtrar por estado',
  })
  @ApiQuery({
    name: 'search',
    required: false,
    description: 'Buscar por nombre, apellido, email o DNI',
  })
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
    example: 10,
  })
  @ApiResponse({ status: 200, description: 'Lista de usuarios' })
  async findAll(
    @Query('rol') rol?: Role,
    @Query('estado') estado?: EstadoUsuario,
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.usuariosService.findByFilters(
      rol,
      estado,
      search,
      page ? parseInt(page) : 1,
      limit ? parseInt(limit) : 10,
    );
  }

  @Get('stats')
  @Roles(Role.ADMINISTRADOR)
  @ApiOperation({ summary: 'Obtener estadísticas de usuarios' })
  @ApiResponse({ status: 200, description: 'Estadísticas de usuarios' })
  async getStats() {
    return this.usuariosService.getStats();
  }

  @Get('me')
  @ApiOperation({ summary: 'Obtener perfil del usuario actual' })
  @ApiResponse({ status: 200, description: 'Datos del usuario actual' })
  async getProfile(@CurrentUser() user: Usuario) {
    return this.usuariosService.findOne(user.id);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Actualizar perfil del usuario actual' })
  @ApiResponse({ status: 200, description: 'Perfil actualizado correctamente' })
  async updateProfile(
    @CurrentUser() user: Usuario,
    @Body() updateUsuarioDto: UpdateUsuarioDto,
  ) {
    // Filtrar campos que el usuario no puede cambiar sobre sí mismo
    const { rol, estado, ...allowedFields } = updateUsuarioDto;
    return this.usuariosService.update(
      user.id,
      allowedFields,
      user.id,
      user.rol,
    );
  }

  @Patch('me/password')
  @ApiOperation({ summary: 'Cambiar contraseña del usuario actual' })
  @ApiResponse({
    status: 200,
    description: 'Contraseña actualizada correctamente',
  })
  @ApiResponse({ status: 401, description: 'Contraseña actual incorrecta' })
  async changePassword(
    @CurrentUser() user: Usuario,
    @Body() updatePasswordDto: UpdatePasswordDto,
  ) {
    return this.usuariosService.updatePassword(
      user.id,
      updatePasswordDto,
      user.id,
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener usuario por ID' })
  @ApiParam({ name: 'id', description: 'UUID del usuario' })
  @ApiResponse({ status: 200, description: 'Datos del usuario' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.usuariosService.findOne(id);
  }

  @Patch(':id')
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR)
  @ApiOperation({ summary: 'Actualizar usuario' })
  @ApiParam({ name: 'id', description: 'UUID del usuario' })
  @ApiResponse({ status: 200, description: 'Usuario actualizado correctamente' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  @ApiResponse({ status: 403, description: 'Sin permisos para actualizar' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateUsuarioDto: UpdateUsuarioDto,
    @CurrentUser() user: Usuario,
  ) {
    return this.usuariosService.update(
      id,
      updateUsuarioDto,
      user.id,
      user.rol,
    );
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @Roles(Role.ADMINISTRADOR)
  @ApiOperation({ summary: 'Eliminar usuario (soft delete)' })
  @ApiParam({ name: 'id', description: 'UUID del usuario' })
  @ApiResponse({ status: 200, description: 'Usuario eliminado correctamente' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  @ApiResponse({
    status: 400,
    description: 'No se puede eliminar el último administrador',
  })
  async remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.usuariosService.remove(id, user.id, user.rol);
  }

  @Patch(':id/restore')
  @Roles(Role.ADMINISTRADOR)
  @ApiOperation({ summary: 'Restaurar usuario eliminado' })
  @ApiParam({ name: 'id', description: 'UUID del usuario' })
  @ApiResponse({ status: 200, description: 'Usuario restaurado correctamente' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  @ApiResponse({ status: 400, description: 'El usuario no está eliminado' })
  async restore(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.usuariosService.restore(id, user.rol);
  }
}