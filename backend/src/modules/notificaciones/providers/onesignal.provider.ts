import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class OneSignalProvider {
  private readonly logger = new Logger(OneSignalProvider.name);
  private readonly appId: string;
  private readonly apiKey: string;
  private readonly enabled: boolean;

  constructor(private configService: ConfigService) {
    this.appId = this.configService.get<string>('ONESIGNAL_APP_ID') || '';
    this.apiKey = this.configService.get<string>('ONESIGNAL_API_KEY') || '';
    this.enabled = !!this.appId && !!this.apiKey;
  }

  async enviar(
    userId: string,
    titulo: string,
    mensaje: string,
    datos?: Record<string, any>,
  ): Promise<boolean> {
    if (!this.enabled) {
      this.logger.warn('OneSignal no configurado. Notificación no enviada.');
      return false;
    }

    try {
      // TODO: Implementar integración real con OneSignal API
      // const url = 'https://onesignal.com/api/v1/notifications';
      // const response = await fetch(url, {
      //   method: 'POST',
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': `Basic ${this.apiKey}`,
      //   },
      //   body: JSON.stringify({
      //     app_id: this.appId,
      //     include_external_user_ids: [userId],
      //     headings: { en: titulo },
      //     contents: { en: mensaje },
      //     data: datos,
      //   }),
      // });

      this.logger.log(
        `[STUB] Push notification enviada a ${userId}: ${titulo}`,
      );
      return true;
    } catch (error) {
      this.logger.error('Error al enviar push notification', error);
      return false;
    }
  }

  async enviarASegmento(
    segmento: string,
    titulo: string,
    mensaje: string,
    datos?: Record<string, any>,
  ): Promise<boolean> {
    if (!this.enabled) {
      this.logger.warn('OneSignal no configurado. Notificación no enviada.');
      return false;
    }

    try {
      this.logger.log(
        `[STUB] Push notification enviada al segmento ${segmento}: ${titulo}`,
      );
      return true;
    } catch (error) {
      this.logger.error('Error al enviar push notification al segmento', error);
      return false;
    }
  }
}