import 'package:freezed_annotation/freezed_annotation.dart';

part 'reclamos_stats_model.freezed.dart';
part 'reclamos_stats_model.g.dart';

/// Reclamos statistics model
@freezed
class ReclamosStatsModel with _$ReclamosStatsModel {
  const ReclamosStatsModel._();

  const factory ReclamosStatsModel({
    @JsonKey(name: 'totalReclamos') @Default(0) int total,
    @JsonKey(name: 'reclamosPorEstado') @Default({}) Map<String, int> reclamosPorEstado,
    @JsonKey(name: 'reclamosPorPrioridad') @Default({}) Map<String, int> porPrioridad,
    @JsonKey(name: 'reclamosPorCategoria') @Default({}) Map<String, int> porCategoria,
    @JsonKey(name: 'reclamosVencidos') @Default(0) int vencidos,
  }) = _ReclamosStatsModel;

  /// Get count for PENDIENTE status
  int get pendientes => reclamosPorEstado['PENDIENTE'] ?? 0;

  /// Get count for EN_CURSO status
  int get enProgreso => reclamosPorEstado['EN_CURSO'] ?? 0;

  /// Get count for RESUELTO status
  int get resueltos => reclamosPorEstado['RESUELTO'] ?? 0;

  /// Get count for CERRADO status
  int get cerrados => reclamosPorEstado['CERRADO'] ?? 0;

  /// Get count for RECHAZADO status
  int get rechazados => reclamosPorEstado['RECHAZADO'] ?? 0;

  /// Get count for ABIERTO status (alias for pendientes)
  int get abiertos => reclamosPorEstado['ABIERTO'] ?? 0;

  factory ReclamosStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ReclamosStatsModelFromJson(json);
}
