import 'package:freezed_annotation/freezed_annotation.dart';

part 'reclamos_stats_model.freezed.dart';
part 'reclamos_stats_model.g.dart';

/// Reclamos statistics model
@freezed
class ReclamosStatsModel with _$ReclamosStatsModel {
  const factory ReclamosStatsModel({
    required int total,
    required int pendientes,
    @JsonKey(name: 'en_progreso') required int enProgreso,
    required int resueltos,
    required int cerrados,
    required int rechazados,
    @JsonKey(name: 'por_categoria') required Map<String, int> porCategoria,
    @JsonKey(name: 'por_prioridad') required Map<String, int> porPrioridad,
  }) = _ReclamosStatsModel;

  factory ReclamosStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ReclamosStatsModelFromJson(json);
}
