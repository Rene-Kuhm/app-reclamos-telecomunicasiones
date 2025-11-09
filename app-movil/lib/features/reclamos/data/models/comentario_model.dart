import 'package:freezed_annotation/freezed_annotation.dart';

part 'comentario_model.freezed.dart';
part 'comentario_model.g.dart';

/// Comentario entity
class Comentario {
  final String id;
  final String contenido;
  final String reclamoId;
  final String usuarioId;
  final String? nombreUsuario;
  final DateTime createdAt;

  const Comentario({
    required this.id,
    required this.contenido,
    required this.reclamoId,
    required this.usuarioId,
    this.nombreUsuario,
    required this.createdAt,
  });
}

/// Comentario data model
@freezed
class ComentarioModel with _$ComentarioModel {
  const factory ComentarioModel({
    required String id,
    required String contenido,
    @JsonKey(name: 'reclamo_id') String? reclamoId,
    @JsonKey(name: 'usuario_id') String? usuarioId,
    @JsonKey(name: 'interno', defaultValue: false) required bool interno,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? usuario,
  }) = _ComentarioModel;

  const ComentarioModel._();

  /// From JSON
  factory ComentarioModel.fromJson(Map<String, dynamic> json) =>
      _$ComentarioModelFromJson(json);

  /// To domain entity
  Comentario toEntity() {
    final nombreUsuario = usuario != null ? usuario!['nombre'] as String? : null;

    return Comentario(
      id: id,
      contenido: contenido,
      reclamoId: reclamoId ?? '',
      usuarioId: usuarioId ?? '',
      nombreUsuario: nombreUsuario,
      createdAt: createdAt,
    );
  }
}

/// Create comentario request
@freezed
class CreateComentarioRequest with _$CreateComentarioRequest {
  const factory CreateComentarioRequest({
    required String contenido,
  }) = _CreateComentarioRequest;

  /// From JSON
  factory CreateComentarioRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateComentarioRequestFromJson(json);
}
