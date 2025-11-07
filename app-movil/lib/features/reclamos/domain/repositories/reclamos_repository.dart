import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../entities/reclamo.dart';
import '../../data/models/comentario_model.dart';
import '../../data/models/archivo_model.dart';
import '../../data/models/reclamos_stats_model.dart';

/// Reclamos repository interface
abstract class ReclamosRepository {
  /// Get all reclamos with optional filters
  Future<Either<ApiError, List<Reclamo>>> getReclamos({
    String? estado,
    String? categoria,
    String? prioridad,
    String? search,
    int? page,
    int? limit,
  });

  /// Get reclamo by ID
  Future<Either<ApiError, Reclamo>> getReclamoById(String id);

  /// Create new reclamo
  Future<Either<ApiError, Reclamo>> createReclamo({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
  });

  /// Update reclamo
  Future<Either<ApiError, Reclamo>> updateReclamo({
    required String id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? prioridad,
    String? estado,
  });

  /// Delete reclamo
  Future<Either<ApiError, void>> deleteReclamo(String id);

  /// Get comentarios for a reclamo
  Future<Either<ApiError, List<Comentario>>> getComentarios(String reclamoId);

  /// Create comentario for a reclamo
  Future<Either<ApiError, Comentario>> createComentario({
    required String reclamoId,
    required String contenido,
  });

  /// Get archivos for a reclamo
  Future<Either<ApiError, List<Archivo>>> getArchivos(String reclamoId);

  /// Upload archivo to a reclamo
  Future<Either<ApiError, Archivo>> uploadArchivo({
    required String reclamoId,
    required String filePath,
    required String fileName,
  });

  /// Delete archivo
  Future<Either<ApiError, void>> deleteArchivo({
    required String reclamoId,
    required String archivoId,
  });

  /// Get reclamos statistics
  Future<Either<ApiError, ReclamosStatsModel>> getStats();
}
