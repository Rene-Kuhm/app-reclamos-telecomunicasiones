import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/reclamo_model.dart';
import '../models/create_reclamo_request.dart';
import '../models/update_reclamo_request.dart';
import '../models/comentario_model.dart';
import '../models/archivo_model.dart';
import '../models/reclamos_stats_model.dart';

/// Reclamos remote data source
class ReclamosRemoteDataSource {
  final DioClient _dioClient;

  ReclamosRemoteDataSource(this._dioClient);

  /// Get all reclamos with optional filters
  Future<List<ReclamoModel>> getReclamos({
    String? estado,
    String? categoria,
    String? prioridad,
    String? search,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};

    if (estado != null) queryParams['estado'] = estado;
    if (categoria != null) queryParams['categoria'] = categoria;
    if (prioridad != null) queryParams['prioridad'] = prioridad;
    if (search != null) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _dioClient.get(
      ApiEndpoints.reclamosList,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ReclamoModel.fromJson(json)).toList();
  }

  /// Get reclamo by ID
  Future<ReclamoModel> getReclamoById(String id) async {
    final response = await _dioClient.get(
      ApiEndpoints.replaceId(ApiEndpoints.reclamoById, id),
    );

    return ReclamoModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Create new reclamo
  Future<ReclamoModel> createReclamo(CreateReclamoRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.createReclamo,
      data: request.toJson(),
    );

    return ReclamoModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Update reclamo
  Future<ReclamoModel> updateReclamo(
    String id,
    UpdateReclamoRequest request,
  ) async {
    final response = await _dioClient.patch(
      ApiEndpoints.replaceId(ApiEndpoints.updateReclamo, id),
      data: request.toJson(),
    );

    return ReclamoModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Delete reclamo
  Future<void> deleteReclamo(String id) async {
    await _dioClient.delete(
      ApiEndpoints.replaceId(ApiEndpoints.deleteReclamo, id),
    );
  }

  /// Get comentarios for a reclamo
  Future<List<ComentarioModel>> getComentarios(String reclamoId) async {
    final response = await _dioClient.get(
      ApiEndpoints.replaceId(ApiEndpoints.reclamoComentarios, reclamoId),
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ComentarioModel.fromJson(json)).toList();
  }

  /// Create comentario for a reclamo
  Future<ComentarioModel> createComentario(
    String reclamoId,
    CreateComentarioRequest request,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.replaceId(ApiEndpoints.createComentario, reclamoId),
      data: request.toJson(),
    );

    return ComentarioModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Get archivos for a reclamo
  Future<List<ArchivoModel>> getArchivos(String reclamoId) async {
    final response = await _dioClient.get(
      ApiEndpoints.replaceId(ApiEndpoints.reclamoArchivos, reclamoId),
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ArchivoModel.fromJson(json)).toList();
  }

  /// Upload archivo to a reclamo
  Future<ArchivoModel> uploadArchivo(
    String reclamoId,
    String filePath,
    String fileName,
  ) async {
    final formData = FormData.fromMap({
      'archivo': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dioClient.post(
      ApiEndpoints.replaceId(ApiEndpoints.uploadArchivo, reclamoId),
      data: formData,
    );

    return ArchivoModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Delete archivo
  Future<void> deleteArchivo(String reclamoId, String archivoId) async {
    await _dioClient.delete(
      ApiEndpoints.replaceIdAndArchivoId(
        ApiEndpoints.deleteArchivo,
        reclamoId,
        archivoId,
      ),
    );
  }

  /// Get reclamos statistics
  Future<ReclamosStatsModel> getStats() async {
    final response = await _dioClient.get(ApiEndpoints.reclamosStats);
    return ReclamosStatsModel.fromJson(response.data['data'] ?? response.data);
  }
}
