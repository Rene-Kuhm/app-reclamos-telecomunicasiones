import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { ConfigService } from '@nestjs/config';
import * as path from 'path';
import * as fs from 'fs';
import { promisify } from 'util';

const unlinkAsync = promisify(fs.unlink);

@Injectable()
export class ArchivosService {
  private readonly logger = new Logger(ArchivosService.name);
  private readonly uploadPath: string;
  private readonly maxFileSize: number;
  private readonly allowedMimeTypes: string[];

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    this.uploadPath =
      this.configService.get<string>('UPLOAD_PATH') || './uploads';
    this.maxFileSize =
      this.configService.get<number>('MAX_FILE_SIZE') || 10 * 1024 * 1024; // 10MB
    this.allowedMimeTypes = [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'text/plain',
      'text/csv',
    ];

    // Crear directorio de uploads si no existe
    if (!fs.existsSync(this.uploadPath)) {
      fs.mkdirSync(this.uploadPath, { recursive: true });
    }
  }

  async upload(
    reclamoId: string,
    file: Express.Multer.File,
    usuarioId: string,
  ) {
    // Verificar que el reclamo existe
    const reclamo = await this.prisma.reclamo.findUnique({
      where: { id: reclamoId },
    });

    if (!reclamo) {
      // Eliminar archivo si el reclamo no existe
      await this.deleteFileFromDisk(file.path);
      throw new NotFoundException('Reclamo no encontrado');
    }

    // Validar tipo de archivo
    if (!this.allowedMimeTypes.includes(file.mimetype)) {
      await this.deleteFileFromDisk(file.path);
      throw new BadRequestException(
        'Tipo de archivo no permitido. Solo se aceptan imágenes, PDFs y documentos de Office.',
      );
    }

    // Validar tamaño
    if (file.size > this.maxFileSize) {
      await this.deleteFileFromDisk(file.path);
      throw new BadRequestException(
        `El archivo excede el tamaño máximo de ${this.maxFileSize / 1024 / 1024}MB`,
      );
    }

    // Guardar en base de datos
    const archivo = await this.prisma.archivo.create({
      data: {
        reclamo_id: reclamoId,
        nombre_original: file.originalname,
        nombre_almacenado: file.filename,
        ruta: file.path,
        mime_type: file.mimetype,
        tamanio_bytes: file.size,
        subido_por_id: usuarioId,
        hash_sha256: '', // TODO: Calculate actual hash
      },
    });

    this.logger.log(
      `Archivo ${file.originalname} subido para reclamo ${reclamoId}`,
    );

    return {
      id: archivo.id,
      nombre: archivo.nombre_original,
      tipo: archivo.mime_type,
      tamano: archivo.tamanio_bytes,
      url: `/api/archivos/${archivo.id}`,
      uploadedAt: archivo.created_at,
    };
  }

  async findAll(reclamoId: string) {
    // Verificar que el reclamo existe
    const reclamo = await this.prisma.reclamo.findUnique({
      where: { id: reclamoId },
    });

    if (!reclamo) {
      throw new NotFoundException('Reclamo no encontrado');
    }

    const archivos = await this.prisma.archivo.findMany({
      where: { reclamo_id: reclamoId },
      include: {
        subido_por: {
          select: {
            nombre: true,
            apellido: true,
            rol: true,
          },
        },
      },
      orderBy: {
        created_at: 'desc',
      },
    });

    return archivos.map((archivo) => ({
      id: archivo.id,
      nombre: archivo.nombre_original,
      tipo: archivo.mime_type,
      tamano: archivo.tamanio_bytes,
      url: `/api/archivos/${archivo.id}`,
      uploadedBy: {
        nombre: `${archivo.subido_por.nombre} ${archivo.subido_por.apellido}`,
        rol: archivo.subido_por.rol,
      },
      uploadedAt: archivo.created_at,
    }));
  }

  async findOne(archivoId: string) {
    const archivo = await this.prisma.archivo.findUnique({
      where: { id: archivoId },
    });

    if (!archivo) {
      throw new NotFoundException('Archivo no encontrado');
    }

    // Verificar que el archivo existe en disco
    if (!fs.existsSync(archivo.ruta)) {
      this.logger.error(
        `Archivo ${archivo.nombre_original} no encontrado en disco: ${archivo.ruta}`,
      );
      throw new NotFoundException('Archivo no encontrado en el sistema');
    }

    return {
      path: archivo.ruta,
      nombre: archivo.nombre_original,
      tipo: archivo.mime_type,
    };
  }

  async delete(archivoId: string, usuarioId: string) {
    const archivo = await this.prisma.archivo.findUnique({
      where: { id: archivoId },
    });

    if (!archivo) {
      throw new NotFoundException('Archivo no encontrado');
    }

    // Eliminar archivo del disco
    try {
      if (fs.existsSync(archivo.ruta)) {
        await unlinkAsync(archivo.ruta);
      }
    } catch (error) {
      this.logger.error('Error al eliminar archivo del disco', error);
    }

    // Eliminar de base de datos
    await this.prisma.archivo.delete({
      where: { id: archivoId },
    });

    this.logger.log(
      `Archivo ${archivo.nombre_original} eliminado por usuario ${usuarioId}`,
    );

    return { message: 'Archivo eliminado correctamente' };
  }

  /**
   * Elimina todos los archivos de un reclamo
   */
  async deleteByReclamo(reclamoId: string) {
    const archivos = await this.prisma.archivo.findMany({
      where: { reclamo_id: reclamoId },
    });

    for (const archivo of archivos) {
      try {
        if (fs.existsSync(archivo.ruta)) {
          await unlinkAsync(archivo.ruta);
        }
      } catch (error) {
        this.logger.error('Error al eliminar archivo del disco', error);
      }
    }

    await this.prisma.archivo.deleteMany({
      where: { reclamo_id: reclamoId },
    });

    this.logger.log(
      `${archivos.length} archivos eliminados del reclamo ${reclamoId}`,
    );
  }

  private async deleteFileFromDisk(filePath: string) {
    try {
      if (fs.existsSync(filePath)) {
        await unlinkAsync(filePath);
      }
    } catch (error) {
      this.logger.error('Error al eliminar archivo del disco', error);
    }
  }

  /**
   * Obtiene estadísticas de archivos
   */
  async getStats() {
    const [totalArchivos, totalTamano, archivosPorTipo] = await Promise.all([
      this.prisma.archivo.count(),
      this.prisma.archivo.aggregate({
        _sum: {
          tamanio_bytes: true,
        },
      }),
      this.prisma.archivo.groupBy({
        by: ['mime_type'],
        _count: true,
        _sum: {
          tamanio_bytes: true,
        },
      }),
    ]);

    return {
      totalArchivos,
      totalTamano: totalTamano._sum.tamanio_bytes || 0,
      totalTamanoMB: Math.round((totalTamano._sum.tamanio_bytes || 0) / 1024 / 1024),
      archivosPorTipo: archivosPorTipo.map((tipo) => ({
        tipo: tipo.mime_type,
        cantidad: tipo._count,
        tamanoTotal: tipo._sum.tamanio_bytes || 0,
        tamanoTotalMB: Math.round((tipo._sum.tamanio_bytes || 0) / 1024 / 1024),
      })),
    };
  }
}