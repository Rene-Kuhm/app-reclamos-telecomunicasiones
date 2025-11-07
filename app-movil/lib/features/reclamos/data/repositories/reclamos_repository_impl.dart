import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/entities/reclamo.dart';
import '../../domain/repositories/reclamos_repository.dart';
import '../datasources/reclamos_remote_datasource.dart';
import '../models/create_reclamo_request.dart';
import '../models/update_reclamo_request.dart';
import '../models/comentario_model.dart';
import '../models/archivo_model.dart';
import '../models/reclamos_stats_model.dart';

/// Reclamos repository implementation
class ReclamosRepositoryImpl implements ReclamosRepository {
  final ReclamosRemoteDataSource _remoteDataSource;

  ReclamosRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<ApiError, List<Reclamo>>> getReclamos({
    String? estado,
    String? categoria,
    String? prioridad,
    String? search,
    int? page,
    int? limit,
  }) async {
    try {
      final models = await _remoteDataSource.getReclamos(
        estado: estado,
        categoria: categoria,
        prioridad: prioridad,
        search: search,
        page: page,
        limit: limit,
      );

      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, Reclamo>> getReclamoById(String id) async {
    try {
      final model = await _remoteDataSource.getReclamoById(id);
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, Reclamo>> createReclamo({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
  }) async {
    try {
      final request = CreateReclamoRequest(
        titulo: titulo,
        descripcion: descripcion,
        categoria: categoria,
        prioridad: prioridad,
      );

      final model = await _remoteDataSource.createReclamo(request);
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, Reclamo>> updateReclamo({
    required String id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? prioridad,
    String? estado,
  }) async {
    try {
      final request = UpdateReclamoRequest(
        titulo: titulo,
        descripcion: descripcion,
        categoria: categoria,
        prioridad: prioridad,
        estado: estado,
      );

      final model = await _remoteDataSource.updateReclamo(id, request);
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, void>> deleteReclamo(String id) async {
    try {
      await _remoteDataSource.deleteReclamo(id);
      return const Right(null);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, List<Comentario>>> getComentarios(String reclamoId) async {
    try {
      final models = await _remoteDataSource.getComentarios(reclamoId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, Comentario>> createComentario({
    required String reclamoId,
    required String contenido,
  }) async {
    try {
      final request = CreateComentarioRequest(contenido: contenido);
      final model = await _remoteDataSource.createComentario(reclamoId, request);
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, List<Archivo>>> getArchivos(String reclamoId) async {
    try {
      final models = await _remoteDataSource.getArchivos(reclamoId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, Archivo>> uploadArchivo({
    required String reclamoId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final model = await _remoteDataSource.uploadArchivo(
        reclamoId,
        filePath,
        fileName,
      );
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, void>> deleteArchivo({
    required String reclamoId,
    required String archivoId,
  }) async {
    try {
      await _remoteDataSource.deleteArchivo(reclamoId, archivoId);
      return const Right(null);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<ApiError, ReclamosStatsModel>> getStats() async {
    try {
      final stats = await _remoteDataSource.getStats();
      return Right(stats);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
