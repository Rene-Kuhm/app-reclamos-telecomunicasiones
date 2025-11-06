import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notificacion_model.dart';

/// Notificaciones remote data source
class NotificacionesRemoteDataSource {
  final DioClient _dioClient;

  NotificacionesRemoteDataSource(this._dioClient);

  /// Get all notificaciones
  Future<List<NotificacionModel>> getNotificaciones() async {
    final response = await _dioClient.get(ApiEndpoints.notificacionesList);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => NotificacionModel.fromJson(json)).toList();
  }

  /// Mark notificacion as read
  Future<NotificacionModel> marcarLeida(String id) async {
    final response = await _dioClient.patch(
      ApiEndpoints.replaceId(ApiEndpoints.marcarLeida, id),
    );
    return NotificacionModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Mark all notificaciones as read
  Future<void> marcarTodasLeidas() async {
    await _dioClient.post(ApiEndpoints.marcarTodasLeidas);
  }

  /// Delete notificacion
  Future<void> deleteNotificacion(String id) async {
    await _dioClient.delete(
      ApiEndpoints.replaceId(ApiEndpoints.deleteNotificacion, id),
    );
  }
}
