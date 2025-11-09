import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/reclamos_remote_datasource.dart';
import '../../data/repositories/reclamos_repository_impl.dart';
import '../../domain/entities/reclamo.dart';
import '../../domain/repositories/reclamos_repository.dart';

/// Reclamos list state
class ReclamosState {
  final List<Reclamo> reclamos;
  final bool isLoading;
  final String? error;
  final String? estadoFilter;
  final String? categoriaFilter;
  final String? prioridadFilter;
  final String? searchQuery;
  final bool hasMore;
  final int currentPage;

  const ReclamosState({
    this.reclamos = const [],
    this.isLoading = false,
    this.error,
    this.estadoFilter,
    this.categoriaFilter,
    this.prioridadFilter,
    this.searchQuery,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ReclamosState copyWith({
    List<Reclamo>? reclamos,
    bool? isLoading,
    String? error,
    String? estadoFilter,
    String? categoriaFilter,
    String? prioridadFilter,
    String? searchQuery,
    bool? hasMore,
    int? currentPage,
  }) {
    return ReclamosState(
      reclamos: reclamos ?? this.reclamos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      estadoFilter: estadoFilter ?? this.estadoFilter,
      categoriaFilter: categoriaFilter ?? this.categoriaFilter,
      prioridadFilter: prioridadFilter ?? this.prioridadFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  ReclamosState clearFilters() {
    return ReclamosState(
      reclamos: reclamos,
      isLoading: isLoading,
      error: error,
      hasMore: hasMore,
      currentPage: currentPage,
    );
  }
}

/// Reclamos repository provider
final reclamosRemoteDataSourceProvider = Provider<ReclamosRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReclamosRemoteDataSource(dioClient);
});

final reclamosRepositoryProvider = Provider<ReclamosRepository>((ref) {
  final remoteDataSource = ref.watch(reclamosRemoteDataSourceProvider);
  return ReclamosRepositoryImpl(remoteDataSource);
});

/// Reclamos state notifier
class ReclamosNotifier extends StateNotifier<ReclamosState> {
  final ReclamosRepository _repository;

  ReclamosNotifier(this._repository) : super(const ReclamosState());

  /// Load reclamos
  Future<void> loadReclamos({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMore: true,
      );
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _repository.getReclamos(
      estado: state.estadoFilter,
      categoria: state.categoriaFilter,
      prioridad: state.prioridadFilter,
      search: state.searchQuery,
      page: refresh ? 1 : state.currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
      (reclamos) {
        final newReclamos = refresh ? reclamos : [...state.reclamos, ...reclamos];

        state = state.copyWith(
          reclamos: newReclamos,
          isLoading: false,
          error: null,
          hasMore: reclamos.length >= 20,
          currentPage: refresh ? 2 : state.currentPage + 1,
        );
      },
    );
  }

  /// Set estado filter
  void setEstadoFilter(String? estado) {
    state = state.copyWith(
      estadoFilter: estado,
      reclamos: [],
      currentPage: 1,
      hasMore: true,
    );
    loadReclamos(refresh: true);
  }

  /// Set categoria filter
  void setCategoriaFilter(String? categoria) {
    state = state.copyWith(
      categoriaFilter: categoria,
      reclamos: [],
      currentPage: 1,
      hasMore: true,
    );
    loadReclamos(refresh: true);
  }

  /// Set prioridad filter
  void setPrioridadFilter(String? prioridad) {
    state = state.copyWith(
      prioridadFilter: prioridad,
      reclamos: [],
      currentPage: 1,
      hasMore: true,
    );
    loadReclamos(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.clearFilters().copyWith(
      reclamos: [],
      currentPage: 1,
      hasMore: true,
    );
    loadReclamos(refresh: true);
  }

  /// Search reclamos
  void searchReclamos(String query) {
    state = state.copyWith(
      searchQuery: query.isEmpty ? null : query,
      reclamos: [],
      currentPage: 1,
      hasMore: true,
    );
    loadReclamos(refresh: true);
  }

  /// Create reclamo
  Future<bool> createReclamo({
    required String titulo,
    required String descripcion,
    required String categoria,
    String? subcategoria,
    required String prioridad,
    String? direccion,
    Map<String, dynamic>? infoContacto,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.createReclamo(
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      subcategoria: subcategoria,
      prioridad: prioridad,
      direccion: direccion,
      infoContacto: infoContacto,
    );

    return result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
        return false;
      },
      (reclamo) {
        state = state.copyWith(
          reclamos: [reclamo, ...state.reclamos],
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Delete reclamo
  Future<bool> deleteReclamo(String id) async {
    final result = await _repository.deleteReclamo(id);

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          reclamos: state.reclamos.where((r) => r.id != id).toList(),
          error: null,
        );
        return true;
      },
    );
  }

  /// Refresh list
  Future<void> refresh() async {
    await loadReclamos(refresh: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Reclamos state provider
final reclamosProvider = StateNotifierProvider<ReclamosNotifier, ReclamosState>((ref) {
  final repository = ref.watch(reclamosRepositoryProvider);
  return ReclamosNotifier(repository);
});
