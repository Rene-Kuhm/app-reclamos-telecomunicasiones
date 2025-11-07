import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../datasources/notificaciones_remote_datasource.dart';

/// Notificaciones repository implementation
class NotificacionesRepositoryImpl implements NotificacionesRepository {
  final NotificacionesRemoteDataSource _remoteDataSource;

  NotificacionesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<ApiError, List<Notificacion>>> getNotificaciones() async {
    try {
      final models = await _remoteDataSource.getNotificaciones();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, Notificacion>> marcarLeida(String id) async {
    try {
      final model = await _remoteDataSource.marcarLeida(id);
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, void>> marcarTodasLeidas() async {
    try {
      await _remoteDataSource.marcarTodasLeidas();
      return const Right(null);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, void>> deleteNotificacion(String id) async {
    try {
      await _remoteDataSource.deleteNotificacion(id);
      return const Right(null);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
