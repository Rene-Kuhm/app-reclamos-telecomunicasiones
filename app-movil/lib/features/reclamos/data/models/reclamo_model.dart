import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/reclamo.dart';

part 'reclamo_model.freezed.dart';
part 'reclamo_model.g.dart';

/// Reclamo data model
@freezed
class ReclamoModel with _$ReclamoModel {
  const factory ReclamoModel({
    required String id,
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
    required String estado,
    @JsonKey(name: 'usuario_id') required String usuarioId,
    @JsonKey(name: 'tecnico_asignado_id') String? tecnicoAsignadoId,
    @JsonKey(name: 'fecha_resolucion') DateTime? fechaResolucion,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    String? numero,
    @JsonKey(name: 'usuario') Map<String, dynamic>? usuario,
    @JsonKey(name: 'tecnico_asignado') Map<String, dynamic>? tecnicoAsignado,
  }) = _ReclamoModel;

  const ReclamoModel._();

  /// From JSON
  factory ReclamoModel.fromJson(Map<String, dynamic> json) =>
      _$ReclamoModelFromJson(json);

  /// To domain entity
  Reclamo toEntity() {
    return Reclamo(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      prioridad: prioridad,
      estado: estado,
      usuarioId: usuarioId,
      tecnicoAsignadoId: tecnicoAsignadoId,
      fechaResolucion: fechaResolucion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// From domain entity
  factory ReclamoModel.fromEntity(Reclamo entity) {
    return ReclamoModel(
      id: entity.id,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      categoria: entity.categoria,
      prioridad: entity.prioridad,
      estado: entity.estado,
      usuarioId: entity.usuarioId,
      tecnicoAsignadoId: entity.tecnicoAsignadoId,
      fechaResolucion: entity.fechaResolucion,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
