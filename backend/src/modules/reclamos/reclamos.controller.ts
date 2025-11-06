import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFile,
  Res,
  StreamableFile,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
  ApiParam,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { createReadStream } from 'fs';
import { ReclamosService } from './reclamos.service';
import { ComentariosService } from './services/comentarios.service';
import { ArchivosService } from './services/archivos.service';
import { AuditoriaService } from './services/auditoria.service';
import { AsignacionService } from './services/asignacion.service';
import {
  CreateReclamoDto,
  UpdateReclamoDto,
  AsignarReclamoDto,
  CerrarReclamoDto,
  RechazarReclamoDto,
  CreateComentarioDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Usuario, Role, EstadoReclamo, PrioridadReclamo } from '@prisma/client';

@ApiTags('Reclamos')
@Controller('reclamos')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ReclamosController {
  constructor(
    private readonly reclamosService: ReclamosService,
    private readonly comentariosService: ComentariosService,
    private readonly archivosService: ArchivosService,
    private readonly auditoriaService: AuditoriaService,
    private readonly asignacionService: AsignacionService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Crear nuevo reclamo' })
  @ApiResponse({ status: 201, description: 'Reclamo creado correctamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  async create(
    @Body() createReclamoDto: CreateReclamoDto,
    @CurrentUser() user: Usuario,
  ) {
    return this.reclamosService.create(createReclamoDto, user.id);
  }

  @Get()
  @ApiOperation({ summary: 'Obtener todos los reclamos' })
  @ApiQuery({
    name: 'estado',
    required: false,
    enum: EstadoReclamo,
    description: 'Filtrar por estado',
  })
  @ApiQuery({
    name: 'prioridad',
    required: false,
    enum: PrioridadReclamo,
    description: 'Filtrar por prioridad',
  })
  @ApiQuery({
    name: 'tipo',
    required: false,
    description: 'Filtrar por tipo de reclamo',
  })
  @ApiQuery({
    name: 'tipoServicio',
    required: false,
    description: 'Filtrar por tipo de servicio',
  })
  @ApiQuery({
    name: 'search',
    required: false,
    description: 'Buscar por código, título o descripción',
  })
  @ApiQuery({
    name: 'fechaInicio',
    required: false,
    description: 'Fecha de inicio (ISO 8601)',
  })
  @ApiQuery({
    name: 'fechaFin',
    required: false,
    description: 'Fecha de fin (ISO 8601)',
  })
  @ApiQuery({
    name: 'soloMis',
    required: false,
    type: Boolean,
    description: 'Solo mostrar mis reclamos (técnicos)',
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
  @ApiResponse({ status: 200, description: 'Lista de reclamos' })
  async findAll(
    @CurrentUser() user: Usuario,
    @Query('estado') estado?: EstadoReclamo,
    @Query('prioridad') prioridad?: PrioridadReclamo,
    @Query('tipo') tipo?: string,
    @Query('tipoServicio') tipoServicio?: string,
    @Query('search') search?: string,
    @Query('fechaInicio') fechaInicio?: string,
    @Query('fechaFin') fechaFin?: string,
    @Query('soloMis') soloMis?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.reclamosService.findByFilters(user.id, user.rol, {
      estado,
      prioridad,
      tipo,
      tipoServicio,
      search,
      fechaInicio: fechaInicio ? new Date(fechaInicio) : undefined,
      fechaFin: fechaFin ? new Date(fechaFin) : undefined,
      soloMis: soloMis === 'true',
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 10,
    });
  }

  @Get('stats')
  @ApiOperation({ summary: 'Obtener estadísticas de reclamos' })
  @ApiResponse({ status: 200, description: 'Estadísticas de reclamos' })
  async getStats(@CurrentUser() user: Usuario) {
    return this.reclamosService.getStats(user.id, user.rol);
  }

  @Get('tecnicos/carga')
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR)
  @ApiOperation({ summary: 'Obtener carga de trabajo de técnicos' })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas de carga de técnicos',
  })
  async getCargaTecnicos() {
    return this.asignacionService.obtenerCargaTecnicos();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener reclamo por ID' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 200, description: 'Datos del reclamo' })
  @ApiResponse({ status: 404, description: 'Reclamo no encontrado' })
  async findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.reclamosService.findOne(id, user.id, user.rol);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({
    status: 200,
    description: 'Reclamo actualizado correctamente',
  })
  @ApiResponse({ status: 404, description: 'Reclamo no encontrado' })
  @ApiResponse({ status: 403, description: 'Sin permisos para actualizar' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateReclamoDto: UpdateReclamoDto,
    @CurrentUser() user: Usuario,
  ) {
    return this.reclamosService.update(id, updateReclamoDto, user.id, user.rol);
  }

  @Post(':id/asignar')
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR, Role.TECNICO)
  @ApiOperation({ summary: 'Asignar técnico a reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 200, description: 'Técnico asignado correctamente' })
  @ApiResponse({ status: 404, description: 'Reclamo no encontrado' })
  @ApiResponse({ status: 400, description: 'Técnico no válido' })
  async asignar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() asignarReclamoDto: AsignarReclamoDto,
    @CurrentUser() user: Usuario,
  ) {
    return this.reclamosService.asignar(id, asignarReclamoDto, user.id, user.rol);
  }

  @Patch(':id/estado/:nuevoEstado')
  @ApiOperation({ summary: 'Cambiar estado de reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiParam({
    name: 'nuevoEstado',
    enum: EstadoReclamo,
    description: 'Nuevo estado',
  })
  @ApiResponse({
    status: 200,
    description: 'Estado actualizado correctamente',
  })
  @ApiResponse({ status: 400, description: 'Transición de estado inválida' })
  async cambiarEstado(
    @Param('id', ParseUUIDPipe) id: string,
    @Param('nuevoEstado') nuevoEstado: EstadoReclamo,
    @Body('motivo') motivo: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.reclamosService.cambiarEstado(
      id,
      nuevoEstado,
      user.id,
      user.rol,
      motivo,
    );
  }

  @Post(':id/cerrar')
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR)
  @ApiOperation({ summary: 'Cerrar reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 200, description: 'Reclamo cerrado correctamente' })
  async cerrar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() cerrarReclamoDto: CerrarReclamoDto,
    @CurrentUser() user: Usuario,
  ) {
    return this.reclamosService.cerrar(id, cerrarReclamoDto, user.id, user.rol);
  }

  @Post(':id/rechazar')
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR)
  @ApiOperation({ summary: 'Rechazar reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 200, description: 'Reclamo rechazado correctamente' })
  async rechazar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() rechazarReclamoDto: RechazarReclamoDto,
    @CurrentUser() user: Usuario,
  ) {
    return this.reclamosService.rechazar(
      id,
      rechazarReclamoDto,
      user.id,
      user.rol,
    );
  }

  // COMENTARIOS
  @Get(':id/comentarios')
  @ApiOperation({ summary: 'Obtener comentarios de un reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiQuery({
    name: 'incluirInternos',
    required: false,
    type: Boolean,
    description: 'Incluir comentarios internos (solo para staff)',
  })
  @ApiResponse({ status: 200, description: 'Lista de comentarios' })
  async getComentarios(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: Usuario,
    @Query('incluirInternos') incluirInternos?: string,
  ) {
    return this.comentariosService.findAll(
      id,
      user.rol,
      incluirInternos === 'true',
    );
  }

  @Post(':id/comentarios')
  @ApiOperation({ summary: 'Agregar comentario a un reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 201, description: 'Comentario creado correctamente' })
  async createComentario(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() createComentarioDto: CreateComentarioDto,
    @CurrentUser() user: Usuario,
  ) {
    return this.comentariosService.create(id, user.id, createComentarioDto);
  }

  @Patch('comentarios/:comentarioId')
  @ApiOperation({ summary: 'Actualizar comentario' })
  @ApiParam({ name: 'comentarioId', description: 'UUID del comentario' })
  @ApiResponse({
    status: 200,
    description: 'Comentario actualizado correctamente',
  })
  async updateComentario(
    @Param('comentarioId', ParseUUIDPipe) comentarioId: string,
    @Body('contenido') contenido: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.comentariosService.update(
      comentarioId,
      user.id,
      user.rol,
      contenido,
    );
  }

  @Delete('comentarios/:comentarioId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Eliminar comentario' })
  @ApiParam({ name: 'comentarioId', description: 'UUID del comentario' })
  @ApiResponse({
    status: 200,
    description: 'Comentario eliminado correctamente',
  })
  async deleteComentario(
    @Param('comentarioId', ParseUUIDPipe) comentarioId: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.comentariosService.delete(comentarioId, user.id, user.rol);
  }

  // ARCHIVOS
  @Get(':id/archivos')
  @ApiOperation({ summary: 'Obtener archivos de un reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 200, description: 'Lista de archivos' })
  async getArchivos(@Param('id', ParseUUIDPipe) id: string) {
    return this.archivosService.findAll(id);
  }

  @Post(':id/archivos')
  @ApiOperation({ summary: 'Subir archivo a un reclamo' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 201, description: 'Archivo subido correctamente' })
  @ApiResponse({ status: 400, description: 'Archivo inválido' })
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const randomName = Array(32)
            .fill(null)
            .map(() => Math.round(Math.random() * 16).toString(16))
            .join('');
          cb(null, `${randomName}${extname(file.originalname)}`);
        },
      }),
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB
      },
    }),
  )
  async uploadArchivo(
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: Usuario,
  ) {
    return this.archivosService.upload(id, file, user.id);
  }

  @Get('archivos/:archivoId')
  @ApiOperation({ summary: 'Descargar archivo' })
  @ApiParam({ name: 'archivoId', description: 'UUID del archivo' })
  @ApiResponse({ status: 200, description: 'Archivo descargado' })
  @ApiResponse({ status: 404, description: 'Archivo no encontrado' })
  async downloadArchivo(
    @Param('archivoId', ParseUUIDPipe) archivoId: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    const archivo = await this.archivosService.findOne(archivoId);
    const file = createReadStream(archivo.path);

    res.set({
      'Content-Type': archivo.tipo,
      'Content-Disposition': `attachment; filename="${archivo.nombre}"`,
    });

    return new StreamableFile(file);
  }

  @Delete('archivos/:archivoId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Eliminar archivo' }}
  @ApiParam({ name: 'archivoId', description: 'UUID del archivo' })
  @ApiResponse({ status: 200, description: 'Archivo eliminado correctamente' })
  async deleteArchivo(
    @Param('archivoId', ParseUUIDPipe) archivoId: string,
    @CurrentUser() user: Usuario,
  ) {
    return this.archivosService.delete(archivoId, user.id);
  }

  // AUDITORÍA
  @Get(':id/auditoria')
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR, Role.TECNICO)
  @ApiOperation({ summary: 'Obtener historial de auditoría de un reclamo' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 200, description: 'Historial de auditoría' })
  async getAuditoria(@Param('id', ParseUUIDPipe) id: string) {
    return this.auditoriaService.obtenerHistorial(id);
  }

  // RECOMENDACIÓN DE TÉCNICO
  @Get(':id/recomendar-tecnico')
  @Roles(Role.ADMINISTRADOR, Role.SUPERVISOR)
  @ApiOperation({ summary: 'Obtener recomendación de técnico para asignar' })
  @ApiParam({ name: 'id', description: 'UUID del reclamo' })
  @ApiResponse({ status: 200, description: 'Técnico recomendado' })
  async recomendarTecnico(@Param('id', ParseUUIDPipe) id: string) {
    return this.asignacionService.recomendarTecnico(id);
  }
}