/**
 * Tipos de enums para compatibilidad con SQLite
 * SQLite no soporta enums nativos, por lo que usamos strings con tipos de TypeScript
 *
 * Este archivo exporta tanto los tipos como constantes que imitan el comportamiento
 * de los enums de PostgreSQL para mantener compatibilidad con el código existente.
 */

// ============= TIPOS =============

export type RolUsuario = 'PROFESIONAL' | 'TECNICO' | 'SUPERVISOR' | 'ADMINISTRADOR';

export type EstadoReclamo = 'ABIERTO' | 'ASIGNADO' | 'EN_CURSO' | 'EN_REVISION' | 'CERRADO' | 'RECHAZADO';

export type PrioridadReclamo = 'BAJA' | 'MEDIA' | 'ALTA' | 'URGENTE';

export type CategoriaReclamo =
  | 'INTERNET_ADSL'
  | 'INTERNET_FIBRA'
  | 'TELEFONO_ADSL'
  | 'TELEFONO_FIBRA'
  | 'TV_SENSA';

export type TipoNotificacion = 'EMAIL' | 'TELEGRAM' | 'PUSH' | 'SMS';

export type EstadoNotificacion = 'PENDIENTE' | 'ENVIADA' | 'FALLIDA' | 'ENTREGADA' | 'LEIDA';

export type EstadoUsuario = 'ACTIVO' | 'INACTIVO' | 'SUSPENDIDO' | 'BLOQUEADO';

export type CanalNotificacion = 'EMAIL' | 'TELEGRAM' | 'PUSH' | 'SMS' | 'SISTEMA';

// ============= ENUM-LIKE CONSTANTS (Compatibilidad con código PostgreSQL) =============

/**
 * RolUsuario enum-like object
 * Uso: RolUsuario.PROFESIONAL, @IsEnum(RolUsuario), etc.
 */
export const RolUsuario = {
  PROFESIONAL: 'PROFESIONAL',
  TECNICO: 'TECNICO',
  SUPERVISOR: 'SUPERVISOR',
  ADMINISTRADOR: 'ADMINISTRADOR',
} as const;

/**
 * EstadoReclamo enum-like object
 */
export const EstadoReclamo = {
  ABIERTO: 'ABIERTO',
  ASIGNADO: 'ASIGNADO',
  EN_CURSO: 'EN_CURSO',
  EN_REVISION: 'EN_REVISION',
  CERRADO: 'CERRADO',
  RECHAZADO: 'RECHAZADO',
} as const;

/**
 * PrioridadReclamo enum-like object
 */
export const PrioridadReclamo = {
  BAJA: 'BAJA',
  MEDIA: 'MEDIA',
  ALTA: 'ALTA',
  URGENTE: 'URGENTE',
} as const;

/**
 * CategoriaReclamo enum-like object
 */
export const CategoriaReclamo = {
  INTERNET_ADSL: 'INTERNET_ADSL',
  INTERNET_FIBRA: 'INTERNET_FIBRA',
  TELEFONO_ADSL: 'TELEFONO_ADSL',
  TELEFONO_FIBRA: 'TELEFONO_FIBRA',
  TV_SENSA: 'TV_SENSA',
} as const;

/**
 * TipoNotificacion enum-like object
 */
export const TipoNotificacion = {
  EMAIL: 'EMAIL',
  TELEGRAM: 'TELEGRAM',
  PUSH: 'PUSH',
  SMS: 'SMS',
} as const;

/**
 * EstadoNotificacion enum-like object
 */
export const EstadoNotificacion = {
  PENDIENTE: 'PENDIENTE',
  ENVIADA: 'ENVIADA',
  FALLIDA: 'FALLIDA',
  ENTREGADA: 'ENTREGADA',
  LEIDA: 'LEIDA',
} as const;

/**
 * EstadoUsuario enum-like object
 */
export const EstadoUsuario = {
  ACTIVO: 'ACTIVO',
  INACTIVO: 'INACTIVO',
  SUSPENDIDO: 'SUSPENDIDO',
  BLOQUEADO: 'BLOQUEADO',
} as const;

/**
 * CanalNotificacion enum-like object
 */
export const CanalNotificacion = {
  EMAIL: 'EMAIL',
  TELEGRAM: 'TELEGRAM',
  PUSH: 'PUSH',
  SMS: 'SMS',
  SISTEMA: 'SISTEMA',
} as const;

// ============= BACKWARDS COMPATIBILITY =============

export const RolUsuarioValues = RolUsuario;
export const EstadoReclamoValues = EstadoReclamo;
export const PrioridadReclamoValues = PrioridadReclamo;
export const CategoriaReclamoValues = CategoriaReclamo;
export const TipoNotificacionValues = TipoNotificacion;
export const EstadoNotificacionValues = EstadoNotificacion;
export const EstadoUsuarioValues = EstadoUsuario;
export const CanalNotificacionValues = CanalNotificacion;
