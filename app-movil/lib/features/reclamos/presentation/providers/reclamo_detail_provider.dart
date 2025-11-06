import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/comentario_model.dart';
import '../../data/models/archivo_model.dart';
import '../../domain/entities/reclamo.dart';
import '../../domain/repositories/reclamos_repository.dart';
import 'reclamos_provider.dart';

/// Reclamo detail state
class ReclamoDetailState {
  final Reclamo? reclamo;
  final List<Comentario> comentarios;
  final List<Archivo> archivos;
  final bool isLoading;
  final bool isLoadingComentarios;
  final bool isLoadingArchivos;
  final String? error;

  const ReclamoDetailState({
    this.reclamo,
    this.comentarios = const [],
    this.archivos = const [],
    this.isLoading = false,
    this.isLoadingComentarios = false,
    this.isLoadingArchivos = false,
    this.error,
  });

  ReclamoDetailState copyWith({
    Reclamo? reclamo,
    List<Comentario>? comentarios,
    List<Archivo>? archivos,
    bool? isLoading,
    bool? isLoadingComentarios,
    bool? isLoadingArchivos,
    String? error,
  }) {
    return ReclamoDetailState(
      reclamo: reclamo ?? this.reclamo,
      comentarios: comentarios ?? this.comentarios,
      archivos: archivos ?? this.archivos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingComentarios: isLoadingComentarios ?? this.isLoadingComentarios,
      isLoadingArchivos: isLoadingArchivos ?? this.isLoadingArchivos,
      error: error,
    );
  }
}

/// Reclamo detail notifier
class ReclamoDetailNotifier extends StateNotifier<ReclamoDetailState> {
  final ReclamosRepository _repository;
  final String reclamoId;

  ReclamoDetailNotifier(this._repository, this.reclamoId)
      : super(const ReclamoDetailState());

  /// Load reclamo details
  Future<void> loadReclamo() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getReclamoById(reclamoId);

    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
      (reclamo) {
        state = state.copyWith(
          reclamo: reclamo,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Load comentarios
  Future<void> loadComentarios() async {
    state = state.copyWith(isLoadingComentarios: true);

    final result = await _repository.getComentarios(reclamoId);

    result.fold(
      (error) {
        state = state.copyWith(
          isLoadingComentarios: false,
          error: error.message,
        );
      },
      (comentarios) {
        state = state.copyWith(
          comentarios: comentarios,
          isLoadingComentarios: false,
        );
      },
    );
  }

  /// Load archivos
  Future<void> loadArchivos() async {
    state = state.copyWith(isLoadingArchivos: true);

    final result = await _repository.getArchivos(reclamoId);

    result.fold(
      (error) {
        state = state.copyWith(
          isLoadingArchivos: false,
          error: error.message,
        );
      },
      (archivos) {
        state = state.copyWith(
          archivos: archivos,
          isLoadingArchivos: false,
        );
      },
    );
  }

  /// Create comentario
  Future<bool> createComentario(String contenido) async {
    final result = await _repository.createComentario(
      reclamoId: reclamoId,
      contenido: contenido,
    );

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (comentario) {
        state = state.copyWith(
          comentarios: [...state.comentarios, comentario],
        );
        return true;
      },
    );
  }

  /// Upload archivo
  Future<bool> uploadArchivo(String filePath, String fileName) async {
    final result = await _repository.uploadArchivo(
      reclamoId: reclamoId,
      filePath: filePath,
      fileName: fileName,
    );

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (archivo) {
        state = state.copyWith(
          archivos: [...state.archivos, archivo],
        );
        return true;
      },
    );
  }

  /// Delete archivo
  Future<bool> deleteArchivo(String archivoId) async {
    final result = await _repository.deleteArchivo(
      reclamoId: reclamoId,
      archivoId: archivoId,
    );

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          archivos: state.archivos.where((a) => a.id != archivoId).toList(),
        );
        return true;
      },
    );
  }

  /// Update reclamo
  Future<bool> updateReclamo({
    String? titulo,
    String? descripcion,
    String? categoria,
    String? prioridad,
    String? estado,
  }) async {
    final result = await _repository.updateReclamo(
      id: reclamoId,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      prioridad: prioridad,
      estado: estado,
    );

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (reclamo) {
        state = state.copyWith(reclamo: reclamo);
        return true;
      },
    );
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadReclamo(),
      loadComentarios(),
      loadArchivos(),
    ]);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Reclamo detail provider factory
final reclamoDetailProvider = StateNotifierProvider.family<
    ReclamoDetailNotifier,
    ReclamoDetailState,
    String
>((ref, reclamoId) {
  final repository = ref.watch(reclamosRepositoryProvider);
  return ReclamoDetailNotifier(repository, reclamoId);
});
