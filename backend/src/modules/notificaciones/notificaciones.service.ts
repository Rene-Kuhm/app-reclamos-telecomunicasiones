import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TelegramProvider } from './providers/telegram.provider';
import { EmailProvider } from './providers/email.provider';
import { OneSignalProvider } from './providers/onesignal.provider';
import { TipoNotificacion, CanalNotificacion } from '../../common/types/prisma-enums';

@Injectable()
export class NotificacionesService {
  private readonly logger = new Logger(NotificacionesService.name);

  constructor(
    private prisma: PrismaService,
    private telegramProvider: TelegramProvider,
    private emailProvider: EmailProvider,
    private oneSignalProvider: OneSignalProvider,
  ) {}

  /**
   * Envía una notificación a un usuario específico
   */
  async enviar(
    usuarioId: string,
    tipo: TipoNotificacion,
    titulo: string,
    mensaje: string,
    datos?: Record<string, any>,
    reclamoId?: string,
  ): Promise<void> {
    try {
      // Obtener usuario
      const usuario = await this.prisma.usuario.findUnique({
        where: { id: usuarioId },
      });

      if (!usuario || !usuario.activo) {
        this.logger.log(
          `Usuario ${usuarioId} está inactivo`,
        );
        return;
      }

      // Crear notificación en base de datos
      const notificacion = await this.prisma.notificacion.create({
        data: {
          usuario_id: usuarioId,
          tipo,
          titulo,
          mensaje,
          datos_envio: datos ? JSON.stringify(datos) : null,
          reclamo_id: reclamoId,
          estado: 'PENDIENTE',
        },
      });

      // Enviar por los canales configurados
      // TODO: Implement preferences logic when preferencias_notif field is properly structured
      // Notifications are saved to database, multi-channel delivery disabled for now

      this.logger.log(
        `Notificación ${tipo} enviada a usuario ${usuarioId}: ${titulo}`,
      );
    } catch (error) {
      this.logger.error('Error al enviar notificación', error);
      // No lanzar error para no interrumpir el flujo principal
    }
  }

  /**
   * Envía notificaciones a múltiples usuarios
   */
  async enviarAVarios(
    usuariosIds: string[],
    tipo: TipoNotificacion,
    titulo: string,
    mensaje: string,
    datos?: Record<string, any>,
  ): Promise<void> {
    const promises = usuariosIds.map((usuarioId) =>
      this.enviar(usuarioId, tipo, titulo, mensaje, datos),
    );

    await Promise.allSettled(promises);
  }

  /**
   * Marca notificación como leída
   */
  async marcarComoLeida(notificacionId: string, usuarioId: string) {
    const notificacion = await this.prisma.notificacion.findFirst({
      where: {
        id: notificacionId,
        usuario_id: usuarioId,
      },
    });

    if (!notificacion) {
      return { message: 'Notificación no encontrada' };
    }

    await this.prisma.notificacion.update({
      where: { id: notificacionId },
      data: {
        leida_at: new Date(),
      },
    });

    return { message: 'Notificación marcada como leída' };
  }

  /**
   * Marca todas las notificaciones de un usuario como leídas
   */
  async marcarTodasComoLeidas(usuarioId: string) {
    const result = await this.prisma.notificacion.updateMany({
      where: {
        usuario_id: usuarioId,
        leida_at: null,
      },
      data: {
        leida_at: new Date(),
      },
    });

    return {
      message: 'Notificaciones marcadas como leídas',
      count: result.count,
    };
  }

  /**
   * Obtiene notificaciones de un usuario
   */
  async obtenerNotificaciones(
    usuarioId: string,
    params?: {
      skip?: number;
      take?: number;
      soloNoLeidas?: boolean;
    },
  ) {
    const { skip = 0, take = 20, soloNoLeidas = false } = params || {};

    const where: any = { usuario_id: usuarioId };

    if (soloNoLeidas) {
      where.leida_at = null;
    }

    const [notificaciones, total, noLeidas] = await Promise.all([
      this.prisma.notificacion.findMany({
        where,
        skip,
        take,
        orderBy: {
          created_at: 'desc',
        },
        include: {
          reclamo: {
            select: {
              numero_reclamo: true,
              titulo: true,
              estado: true,
            },
          },
        },
      }),
      this.prisma.notificacion.count({ where }),
      this.prisma.notificacion.count({
        where: {
          usuario_id: usuarioId,
          leida_at: null,
        },
      }),
    ]);

    return {
      data: notificaciones,
      total,
      noLeidas,
      page: Math.floor(skip / take) + 1,
      pages: Math.ceil(total / take),
    };
  }

  /**
   * Elimina notificación
   */
  async eliminar(notificacionId: string, usuarioId: string) {
    const notificacion = await this.prisma.notificacion.findFirst({
      where: {
        id: notificacionId,
        usuario_id: usuarioId,
      },
    });

    if (!notificacion) {
      return { message: 'Notificación no encontrada' };
    }

    await this.prisma.notificacion.delete({
      where: { id: notificacionId },
    });

    return { message: 'Notificación eliminada' };
  }

  /**
   * Actualiza preferencias de notificación (stored as JSON in Usuario.preferencias_notif)
   */
  async actualizarPreferencias(
    usuarioId: string,
    preferencias: {
      canalEmail?: boolean;
      canalTelegram?: boolean;
      canalPush?: boolean;
      telegramChatId?: string;
      tiposEmail?: TipoNotificacion[];
      tiposTelegram?: TipoNotificacion[];
      tiposPush?: TipoNotificacion[];
    },
  ) {
    // Update preferencias_notif JSON field in Usuario
    const updated = await this.prisma.usuario.update({
      where: { id: usuarioId },
      data: {
        preferencias_notif: JSON.stringify(preferencias),
      },
    });

    return { ...preferencias, usuarioId };
  }

  /**
   * Obtiene preferencias de notificación (from Usuario.preferencias_notif)
   */
  async obtenerPreferencias(usuarioId: string) {
    const usuario = await this.prisma.usuario.findUnique({
      where: { id: usuarioId },
      select: { preferencias_notif: true },
    });

    if (!usuario || !usuario.preferencias_notif) {
      // Devolver preferencias por defecto
      return {
        usuarioId,
        canalEmail: true,
        canalTelegram: false,
        canalPush: true,
        tiposEmail: Object.values(TipoNotificacion),
        tiposTelegram: [],
        tiposPush: Object.values(TipoNotificacion),
      };
    }

    try {
      const preferencias = JSON.parse(usuario.preferencias_notif);
      return { ...preferencias, usuarioId };
    } catch {
      // Si hay error al parsear, devolver defaults
      return {
        usuarioId,
        canalEmail: true,
        canalTelegram: false,
        canalPush: true,
        tiposEmail: Object.values(TipoNotificacion),
        tiposTelegram: [],
        tiposPush: Object.values(TipoNotificacion),
      };
    }
  }

  // Métodos auxiliares privados
  private debeEnviarPorCanal(
    tipo: TipoNotificacion,
    canal: CanalNotificacion,
    preferencias: any,
  ): boolean {
    const tiposKey = `tipos${canal.charAt(0).toUpperCase()}${canal.slice(1).toLowerCase()}`;
    const tiposHabilitados = preferencias[tiposKey] || [];

    return tiposHabilitados.includes(tipo);
  }

  private generarHTMLEmail(
    titulo: string,
    mensaje: string,
    datos?: Record<string, any>,
  ): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
          .content { background: #f9f9f9; padding: 20px; border: 1px solid #ddd; }
          .footer { text-align: center; padding: 20px; font-size: 12px; color: #777; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>${titulo}</h2>
          </div>
          <div class="content">
            <p>${mensaje}</p>
            ${datos ? `<pre>${JSON.stringify(datos, null, 2)}</pre>` : ''}
          </div>
          <div class="footer">
            <p>Sistema de Gestión de Reclamos de Telecomunicaciones</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }
}