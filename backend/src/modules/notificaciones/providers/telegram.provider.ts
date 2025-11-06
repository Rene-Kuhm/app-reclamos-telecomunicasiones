import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class TelegramProvider {
  private readonly logger = new Logger(TelegramProvider.name);
  private readonly botToken: string;
  private readonly enabled: boolean;

  constructor(private configService: ConfigService) {
    this.botToken = this.configService.get<string>('TELEGRAM_BOT_TOKEN') || '';
    this.enabled = !!this.botToken;
  }

  async enviar(chatId: string, mensaje: string): Promise<boolean> {
    if (!this.enabled) {
      this.logger.warn('Telegram no configurado. Mensaje no enviado.');
      return false;
    }

    try {
      // TODO: Implementar integración real con Telegram Bot API
      // const url = `https://api.telegram.org/bot${this.botToken}/sendMessage`;
      // const response = await fetch(url, {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify({
      //     chat_id: chatId,
      //     text: mensaje,
      //     parse_mode: 'HTML',
      //   }),
      // });

      this.logger.log(`[STUB] Telegram enviado a ${chatId}: ${mensaje}`);
      return true;
    } catch (error) {
      this.logger.error('Error al enviar mensaje de Telegram', error);
      return false;
    }
  }

  async enviarConBotones(
    chatId: string,
    mensaje: string,
    botones: Array<{ text: string; url?: string; callback_data?: string }>,
  ): Promise<boolean> {
    if (!this.enabled) {
      this.logger.warn('Telegram no configurado. Mensaje no enviado.');
      return false;
    }

    try {
      this.logger.log(
        `[STUB] Telegram con botones enviado a ${chatId}: ${mensaje}`,
      );
      return true;
    } catch (error) {
      this.logger.error('Error al enviar mensaje de Telegram con botones', error);
      return false;
    }
  }
}