import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notificacion.dart';

part 'notificacion_model.freezed.dart';
part 'notificacion_model.g.dart';

/// Notificacion data model
@freezed
class NotificacionModel with _$NotificacionModel {
  const factory NotificacionModel({
    required String id,
    @JsonKey(name: 'usuario_id') required String usuarioId,
    @JsonKey(name: 'reclamo_id') String? reclamoId,
    required String tipo,
    required String estado,
    required String titulo,
    required String mensaje,
    @JsonKey(name: 'datos_envio') dynamic datosEnvio,
    @JsonKey(name: 'intentos_envio') int? intentosEnvio,
    @JsonKey(name: 'enviada_at') DateTime? enviadaAt,
    @JsonKey(name: 'entregada_at') DateTime? entregadaAt,
    @JsonKey(name: 'leida_at') DateTime? leidaAt,
    @JsonKey(name: 'error_mensaje') String? errorMensaje,
    dynamic metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    dynamic reclamo,
  }) = _NotificacionModel;

  const NotificacionModel._();

  /// Helper to check if read
  bool get leida => leidaAt != null;

  /// From JSON
  factory NotificacionModel.fromJson(Map<String, dynamic> json) =>
      _$NotificacionModelFromJson(json);

  /// To domain entity
  Notificacion toEntity() {
    return Notificacion(
      id: id,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      leida: leida,
      usuarioId: usuarioId,
      reclamoId: reclamoId,
      createdAt: createdAt,
    );
  }
}

