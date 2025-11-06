import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TelegramProvider } from './providers/telegram.provider';
import { EmailProvider } from './providers/email.provider';
import { OneSignalProvider } from './providers/onesignal.provider';
import { TipoNotificacion, CanalNotificacion } from '@prisma/client';

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
      // Obtener preferencias del usuario
      const usuario = await this.prisma.usuario.findUnique({
        where: { id: usuarioId },
        include: {
          preferenciaNotificacion: true,
        },
      });

      if (!usuario || !usuario.notificacionesEnabled) {
        this.logger.log(
          `Usuario ${usuarioId} tiene notificaciones deshabilitadas`,
        );
        return;
      }

      // Crear notificación en base de datos
      const notificacion = await this.prisma.notificacion.create({
        data: {
          usuarioId,
          tipo,
          titulo,
          mensaje,
          datos: datos as any,
          reclamoId,
          leida: false,
        },
      });

      // Enviar por los canales configurados
      const preferencias = usuario.preferenciaNotificacion;

      if (preferencias) {
        // Email
        if (
          preferencias.canalEmail &&
          this.debeEnviarPorCanal(tipo, CanalNotificacion.EMAIL, preferencias)
        ) {
          await this.emailProvider.enviar(
            usuario.email,
            titulo,
            this.generarHTMLEmail(titulo, mensaje, datos),
            mensaje,
          );
          this.logger.log(`Email enviado a ${usuario.email}`);
        }

        // Telegram
        if (
          preferencias.canalTelegram &&
          preferencias.telegramChatId &&
          this.debeEnviarPorCanal(
            tipo,
            CanalNotificacion.TELEGRAM,
            preferencias,
          )
        ) {
          await this.telegramProvider.enviar(
            preferencias.telegramChatId,
            `<b>${titulo}</b>\n\n${mensaje}`,
          );
          this.logger.log(
            `Telegram enviado a chat ${preferencias.telegramChatId}`,
          );
        }

        // Push
        if (
          preferencias.canalPush &&
          this.debeEnviarPorCanal(tipo, CanalNotificacion.PUSH, preferencias)
        ) {
          await this.oneSignalProvider.enviar(usuarioId, titulo, mensaje, datos);
          this.logger.log(`Push enviado a usuario ${usuarioId}`);
        }
      }

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
        usuarioId,
      },
    });

    if (!notificacion) {
      return { message: 'Notificación no encontrada' };
    }

    await this.prisma.notificacion.update({
      where: { id: notificacionId },
      data: {
        leida: true,
        fechaLectura: new Date(),
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
        usuarioId,
        leida: false,
      },
      data: {
        leida: true,
        fechaLectura: new Date(),
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

    const where: any = { usuarioId };

    if (soloNoLeidas) {
      where.leida = false;
    }

    const [notificaciones, total, noLeidas] = await Promise.all([
      this.prisma.notificacion.findMany({
        where,
        skip,
        take,
        orderBy: {
          createdAt: 'desc',
        },
        include: {
          reclamo: {
            select: {
              codigo: true,
              titulo: true,
              estado: true,
            },
          },
        },
      }),
      this.prisma.notificacion.count({ where }),
      this.prisma.notificacion.count({
        where: {
          usuarioId,
          leida: false,
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
        usuarioId,
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
   * Actualiza preferencias de notificación
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
    // Verificar si ya tiene preferencias
    const existentes = await this.prisma.preferenciaNotificacion.findUnique({
      where: { usuarioId },
    });

    if (existentes) {
      // Actualizar
      const updated = await this.prisma.preferenciaNotificacion.update({
        where: { usuarioId },
        data: preferencias as any,
      });

      return updated;
    } else {
      // Crear
      const created = await this.prisma.preferenciaNotificacion.create({
        data: {
          usuarioId,
          ...preferencias,
        } as any,
      });

      return created;
    }
  }

  /**
   * Obtiene preferencias de notificación
   */
  async obtenerPreferencias(usuarioId: string) {
    const preferencias = await this.prisma.preferenciaNotificacion.findUnique({
      where: { usuarioId },
    });

    if (!preferencias) {
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

    return preferencias;
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