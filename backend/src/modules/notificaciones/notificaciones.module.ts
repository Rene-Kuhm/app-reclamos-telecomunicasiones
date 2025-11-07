import { Module } from '@nestjs/common';
import { NotificacionesService } from './notificaciones.service';
import { NotificacionesController } from './notificaciones.controller';
import { PrismaModule } from '../../prisma/prisma.module';
import { TelegramProvider } from './providers/telegram.provider';
import { EmailProvider } from './providers/email.provider';
import { OneSignalProvider } from './providers/onesignal.provider';

@Module({
  imports: [PrismaModule],
  controllers: [NotificacionesController],
  providers: [
    NotificacionesService,
    TelegramProvider,
    EmailProvider,
    OneSignalProvider,
  ],
  exports: [NotificacionesService],
})
export class NotificacionesModule {}