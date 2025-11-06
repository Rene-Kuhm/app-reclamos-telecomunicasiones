import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_reclamo_request.freezed.dart';
part 'update_reclamo_request.g.dart';

/// Update reclamo request model
@freezed
class UpdateReclamoRequest with _$UpdateReclamoRequest {
  const factory UpdateReclamoRequest({
    String? titulo,
    String? descripcion,
    String? categoria,
    String? prioridad,
    String? estado,
  }) = _UpdateReclamoRequest;

  /// From JSON
  factory UpdateReclamoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateReclamoRequestFromJson(json);
}
