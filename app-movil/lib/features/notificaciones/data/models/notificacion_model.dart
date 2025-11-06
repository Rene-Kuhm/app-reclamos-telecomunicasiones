import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notificacion.dart';

part 'notificacion_model.freezed.dart';
part 'notificacion_model.g.dart';

/// Notificacion data model
@freezed
class NotificacionModel with _$NotificacionModel {
  const factory NotificacionModel({
    required String id,
    required String titulo,
    required String mensaje,
    required String tipo,
    required bool leida,
    @JsonKey(name: 'usuario_id') required String usuarioId,
    @JsonKey(name: 'reclamo_id') String? reclamoId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _NotificacionModel;

  const NotificacionModel._();

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
