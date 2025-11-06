import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../entities/notificacion.dart';

/// Notificaciones repository interface
abstract class NotificacionesRepository {
  /// Get all notificaciones
  Future<Either<ApiError, List<Notificacion>>> getNotificaciones();

  /// Mark notificacion as read
  Future<Either<ApiError, Notificacion>> marcarLeida(String id);

  /// Mark all notificaciones as read
  Future<Either<ApiError, void>> marcarTodasLeidas();

  /// Delete notificacion
  Future<Either<ApiError, void>> deleteNotificacion(String id);
}
