import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/reclamo.dart';

part 'reclamo_model.freezed.dart';
part 'reclamo_model.g.dart';

/// Reclamo data model
@freezed
class ReclamoModel with _$ReclamoModel {
  const factory ReclamoModel({
    required String id,
    @JsonKey(name: 'numero_reclamo') required String numeroReclamo,
    required String titulo,
    required String descripcion,
    required String categoria,
    String? subcategoria,
    required String prioridad,
    required String estado,
    String? direccion,
    double? latitud,
    double? longitud,
    @JsonKey(name: 'id_profesional') required String usuarioId,
    @JsonKey(name: 'id_tecnico_asignado') String? tecnicoAsignadoId,
    @JsonKey(name: 'fecha_creacion') required DateTime fechaCreacion,
    @JsonKey(name: 'fecha_asignacion') DateTime? fechaAsignacion,
    @JsonKey(name: 'fecha_inicio_trabajo') DateTime? fechaInicioTrabajo,
    @JsonKey(name: 'fecha_resolucion') DateTime? fechaResolucion,
    @JsonKey(name: 'fecha_cierre') DateTime? fechaCierre,
    @JsonKey(name: 'sla_respuesta_horas', defaultValue: 24) required int slaRespuestaHoras,
    @JsonKey(name: 'sla_resolucion_horas', defaultValue: 72) required int slaResolucionHoras,
    @JsonKey(name: 'sla_vencimiento') DateTime? slaVencimiento,
    @JsonKey(name: 'sla_cumplido') bool? slaCumplido,
    @JsonKey(name: 'notas_resolucion') String? notasResolucion,
    int? calificacion,
    @JsonKey(name: 'comentario_calificacion') String? comentarioCalificacion,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'profesional') Map<String, dynamic>? usuario,
    @JsonKey(name: 'tecnico_asignado') Map<String, dynamic>? tecnicoAsignado,
    @JsonKey(name: '_count') Map<String, dynamic>? count,
    @JsonKey(name: 'estadoVencido') bool? estadoVencido,
    @JsonKey(name: 'horasRestantes') int? horasRestantes,
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
      numero: numeroReclamo,
    );
  }

  /// From domain entity
  factory ReclamoModel.fromEntity(Reclamo entity) {
    return ReclamoModel(
      id: entity.id,
      numeroReclamo: entity.numero ?? '',
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      categoria: entity.categoria,
      prioridad: entity.prioridad,
      estado: entity.estado,
      usuarioId: entity.usuarioId,
      tecnicoAsignadoId: entity.tecnicoAsignadoId,
      fechaCreacion: entity.createdAt,
      fechaResolucion: entity.fechaResolucion,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      slaRespuestaHoras: 24,
      slaResolucionHoras: 72,
    );
  }
}
