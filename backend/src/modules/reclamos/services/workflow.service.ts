import {
  Injectable,
  BadRequestException,
  Logger,
  ForbiddenException,
} from '@nestjs/common';
import { EstadoReclamo, Role } from '@prisma/client';

@Injectable()
export class WorkflowService {
  private readonly logger = new Logger(WorkflowService.name);

  // Mapa de transiciones válidas de estado
  private readonly validTransitions: Record<
    EstadoReclamo,
    EstadoReclamo[]
  > = {
    [EstadoReclamo.ABIERTO]: [
      EstadoReclamo.ASIGNADO,
      EstadoReclamo.RECHAZADO,
      EstadoReclamo.CERRADO,
    ],
    [EstadoReclamo.ASIGNADO]: [
      EstadoReclamo.EN_CURSO,
      EstadoReclamo.ABIERTO,
      EstadoReclamo.RECHAZADO,
    ],
    [EstadoReclamo.EN_CURSO]: [
      EstadoReclamo.EN_REVISION,
      EstadoReclamo.ASIGNADO,
      EstadoReclamo.RECHAZADO,
    ],
    [EstadoReclamo.EN_REVISION]: [
      EstadoReclamo.CERRADO,
      EstadoReclamo.EN_CURSO,
      EstadoReclamo.RECHAZADO,
    ],
    [EstadoReclamo.CERRADO]: [],
    [EstadoReclamo.RECHAZADO]: [EstadoReclamo.ABIERTO],
  };

  // Roles permitidos para cada transición
  private readonly rolePermissions: Record<
    EstadoReclamo,
    Partial<Record<EstadoReclamo, Role[]>>
  > = {
    [EstadoReclamo.ABIERTO]: {
      [EstadoReclamo.ASIGNADO]: [
        Role.ADMINISTRADOR,
        Role.SUPERVISOR,
        Role.TECNICO,
      ],
      [EstadoReclamo.RECHAZADO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
      [EstadoReclamo.CERRADO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
    },
    [EstadoReclamo.ASIGNADO]: {
      [EstadoReclamo.EN_CURSO]: [
        Role.ADMINISTRADOR,
        Role.SUPERVISOR,
        Role.TECNICO,
      ],
      [EstadoReclamo.ABIERTO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
      [EstadoReclamo.RECHAZADO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
    },
    [EstadoReclamo.EN_CURSO]: {
      [EstadoReclamo.EN_REVISION]: [
        Role.ADMINISTRADOR,
        Role.SUPERVISOR,
        Role.TECNICO,
      ],
      [EstadoReclamo.ASIGNADO]: [
        Role.ADMINISTRADOR,
        Role.SUPERVISOR,
        Role.TECNICO,
      ],
      [EstadoReclamo.RECHAZADO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
    },
    [EstadoReclamo.EN_REVISION]: {
      [EstadoReclamo.CERRADO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
      [EstadoReclamo.EN_CURSO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
      [EstadoReclamo.RECHAZADO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
    },
    [EstadoReclamo.CERRADO]: {},
    [EstadoReclamo.RECHAZADO]: {
      [EstadoReclamo.ABIERTO]: [Role.ADMINISTRADOR, Role.SUPERVISOR],
    },
  };

  /**
   * Valida si una transición de estado es válida
   */
  validateTransition(
    currentState: EstadoReclamo,
    newState: EstadoReclamo,
  ): boolean {
    if (currentState === newState) {
      return true; // No hay transición
    }

    const validNextStates = this.validTransitions[currentState];

    if (!validNextStates || !validNextStates.includes(newState)) {
      throw new BadRequestException(
        `Transición inválida de ${currentState} a ${newState}`,
      );
    }

    return true;
  }

  /**
   * Valida si un usuario tiene permisos para realizar una transición
   */
  validateUserPermission(
    currentState: EstadoReclamo,
    newState: EstadoReclamo,
    userRole: Role,
    isAssignedTechnician: boolean = false,
  ): boolean {
    if (currentState === newState) {
      return true; // No hay transición
    }

    // Los administradores tienen permisos completos
    if (userRole === Role.ADMINISTRADOR) {
      return true;
    }

    const allowedRoles = this.rolePermissions[currentState]?.[newState];

    if (!allowedRoles) {
      throw new ForbiddenException(
        'No tienes permisos para realizar esta transición',
      );
    }

    // Si es un técnico, verificar que sea el técnico asignado
    if (userRole === Role.TECNICO && !isAssignedTechnician) {
      throw new ForbiddenException(
        'Solo el técnico asignado puede cambiar el estado',
      );
    }

    if (!allowedRoles.includes(userRole)) {
      throw new ForbiddenException(
        `El rol ${userRole} no tiene permisos para esta transición`,
      );
    }

    return true;
  }

  /**
   * Obtiene los próximos estados válidos desde un estado actual
   */
  getNextValidStates(currentState: EstadoReclamo): EstadoReclamo[] {
    return this.validTransitions[currentState] || [];
  }

  /**
   * Obtiene el mensaje de descripción de un cambio de estado
   */
  getTransitionMessage(
    currentState: EstadoReclamo,
    newState: EstadoReclamo,
  ): string {
    const messages: Record<string, string> = {
      [`${EstadoReclamo.ABIERTO}-${EstadoReclamo.ASIGNADO}`]:
        'Reclamo asignado a técnico',
      [`${EstadoReclamo.ASIGNADO}-${EstadoReclamo.EN_CURSO}`]:
        'Técnico comenzó a trabajar en el reclamo',
      [`${EstadoReclamo.EN_CURSO}-${EstadoReclamo.EN_REVISION}`]:
        'Reclamo en revisión',
      [`${EstadoReclamo.EN_REVISION}-${EstadoReclamo.CERRADO}`]:
        'Reclamo cerrado',
      [`${EstadoReclamo.ABIERTO}-${EstadoReclamo.RECHAZADO}`]:
        'Reclamo rechazado',
      [`${EstadoReclamo.RECHAZADO}-${EstadoReclamo.ABIERTO}`]:
        'Reclamo reabierto',
    };

    const key = `${currentState}-${newState}`;
    return messages[key] || `Estado cambiado de ${currentState} a ${newState}`;
  }

  /**
   * Calcula el SLA (tiempo de resolución) basado en la prioridad
   */
  calculateSLA(prioridad: string): Date {
    const now = new Date();
    let hoursToAdd = 72; // Por defecto 72 horas (BAJA)

    switch (prioridad) {
      case 'URGENTE':
        hoursToAdd = 4;
        break;
      case 'ALTA':
        hoursToAdd = 24;
        break;
      case 'MEDIA':
        hoursToAdd = 48;
        break;
      case 'BAJA':
        hoursToAdd = 72;
        break;
    }

    const sla = new Date(now.getTime() + hoursToAdd * 60 * 60 * 1000);
    return sla;
  }

  /**
   * Verifica si un reclamo está vencido
   */
  isOverdue(fechaLimite: Date): boolean {
    return new Date() > fechaLimite;
  }

  /**
   * Calcula el tiempo restante en horas
   */
  getTimeRemaining(fechaLimite: Date): number {
    const now = new Date();
    const diff = fechaLimite.getTime() - now.getTime();
    return Math.floor(diff / (1000 * 60 * 60)); // Horas
  }
}