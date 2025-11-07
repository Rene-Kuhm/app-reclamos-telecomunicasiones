import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reclamos_stats_model.dart';
import '../../data/repositories/reclamos_repository_impl.dart';
import 'reclamos_provider.dart';

/// Reclamos stats provider using FutureProvider
final reclamosStatsProvider = FutureProvider<ReclamosStatsModel>((ref) async {
  final repository = ref.watch(reclamosRepositoryProvider);
  final result = await repository.getStats();

  return result.fold(
    (error) => throw Exception(error.message),
    (stats) => stats,
  );
});
