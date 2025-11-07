import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class EmailProvider {
  private readonly logger = new Logger(EmailProvider.name);
  private readonly enabled: boolean;
  private readonly fromEmail: string;
  private readonly fromName: string;

  constructor(private configService: ConfigService) {
    this.enabled = this.configService.get<boolean>('EMAIL_ENABLED') || false;
    this.fromEmail =
      this.configService.get<string>('EMAIL_FROM') ||
      'noreply@reclamos.com';
    this.fromName =
      this.configService.get<string>('EMAIL_FROM_NAME') ||
      'Sistema de Reclamos';
  }

  async enviar(
    to: string,
    subject: string,
    html: string,
    text?: string,
  ): Promise<boolean> {
    if (!this.enabled) {
      this.logger.warn('Email no configurado. Mensaje no enviado.');
      return false;
    }

    try {
      // TODO: Implementar integración real con servicio de email
      // Opciones: NodeMailer, SendGrid, AWS SES, Mailgun, etc.
      // const transporter = nodemailer.createTransporter({...});
      // await transporter.sendMail({
      //   from: `${this.fromName} <${this.fromEmail}>`,
      //   to,
      //   subject,
      //   html,
      //   text,
      // });

      this.logger.log(`[STUB] Email enviado a ${to}: ${subject}`);
      return true;
    } catch (error) {
      this.logger.error('Error al enviar email', error);
      return false;
    }
  }

  async enviarPlantilla(
    to: string,
    plantilla: string,
    datos: Record<string, any>,
  ): Promise<boolean> {
    // TODO: Implementar sistema de plantillas (Handlebars, EJS, etc.)
    const subject = this.generarSubject(plantilla, datos);
    const html = this.generarHTML(plantilla, datos);

    return this.enviar(to, subject, html);
  }

  private generarSubject(plantilla: string, datos: any): string {
    const subjects: Record<string, string> = {
      'reclamo-creado': `Reclamo ${datos.codigo} creado`,
      'reclamo-asignado': `Reclamo ${datos.codigo} asignado`,
      'reclamo-cerrado': `Reclamo ${datos.codigo} cerrado`,
      'reclamo-comentario': `Nuevo comentario en reclamo ${datos.codigo}`,
    };

    return (subjects as Record<string, string>)[plantilla] || 'Notificación del sistema';
  }

  private generarHTML(plantilla: string, datos: any): string {
    // TODO: Usar un motor de plantillas real
    const plantillas: Record<string, string> = {
      'reclamo-creado': `
        <h2>Reclamo Creado</h2>
        <p>Se ha creado un nuevo reclamo con el código <strong>${datos.codigo}</strong>.</p>
        <p><strong>Título:</strong> ${datos.titulo}</p>
        <p><strong>Descripción:</strong> ${datos.descripcion}</p>
        <p><strong>Prioridad:</strong> ${datos.prioridad}</p>
        <p>Puede ver los detalles en el sistema.</p>
      `,
      'reclamo-asignado': `
        <h2>Reclamo Asignado</h2>
        <p>El reclamo <strong>${datos.codigo}</strong> ha sido asignado a ${datos.tecnico}.</p>
        <p>Estado actual: ${datos.estado}</p>
      `,
      'reclamo-cerrado': `
        <h2>Reclamo Cerrado</h2>
        <p>El reclamo <strong>${datos.codigo}</strong> ha sido cerrado.</p>
        <p><strong>Solución:</strong> ${datos.solucion}</p>
      `,
    };

    return (
      (plantillas as Record<string, string>)[plantilla] ||
      `<p>Tienes una nueva notificación del sistema.</p>`
    );
  }
}