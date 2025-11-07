/// API endpoint constants
class ApiEndpoints {
  // Base paths
  static const String auth = '/auth';
  static const String usuarios = '/usuarios';
  static const String reclamos = '/reclamos';
  static const String notificaciones = '/notificaciones';

  // Auth endpoints
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refresh = '$auth/refresh';
  static const String changePassword = '$auth/change-password';
  static const String logout = '$auth/logout';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';

  // User endpoints
  static const String me = '$usuarios/me';
  static const String updateProfile = '$usuarios/me';
  static const String userById = '$usuarios/:id';

  // Reclamos endpoints
  static const String reclamosList = reclamos;
  static const String createReclamo = reclamos;
  static const String reclamoById = '$reclamos/:id';
  static const String updateReclamo = '$reclamos/:id';
  static const String deleteReclamo = '$reclamos/:id';
  static const String reclamosStats = '$reclamos/stats';
  static const String reclamoComentarios = '$reclamos/:id/comentarios';
  static const String createComentario = '$reclamos/:id/comentarios';
  static const String reclamoArchivos = '$reclamos/:id/archivos';
  static const String uploadArchivo = '$reclamos/:id/archivos';
  static const String deleteArchivo = '$reclamos/:id/archivos/:archivoId';
  static const String asignarReclamo = '$reclamos/:id/asignar';
  static const String cambiarEstado = '$reclamos/:id/estado';

  // Notificaciones endpoints
  static const String notificacionesList = notificaciones;
  static const String marcarLeida = '$notificaciones/:id/leer';
  static const String marcarTodasLeidas = '$notificaciones/marcar-todas-leidas';
  static const String deleteNotificacion = '$notificaciones/:id';

  // Helper methods to replace path parameters
  static String replaceId(String endpoint, String id) {
    return endpoint.replaceAll(':id', id);
  }

  static String replaceIdAndArchivoId(String endpoint, String id, String archivoId) {
    return endpoint.replaceAll(':id', id).replaceAll(':archivoId', archivoId);
  }
}
