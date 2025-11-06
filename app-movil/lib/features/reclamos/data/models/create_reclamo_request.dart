import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_reclamo_request.freezed.dart';
part 'create_reclamo_request.g.dart';

/// Create reclamo request model
@freezed
class CreateReclamoRequest with _$CreateReclamoRequest {
  const factory CreateReclamoRequest({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
  }) = _CreateReclamoRequest;

  /// From JSON
  factory CreateReclamoRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReclamoRequestFromJson(json);
}
