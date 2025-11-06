import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notificaciones_remote_datasource.dart';
import '../../data/repositories/notificaciones_repository_impl.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificaciones_repository.dart';

/// Notificaciones state
class NotificacionesState {
  final List<Notificacion> notificaciones;
  final bool isLoading;
  final String? error;

  const NotificacionesState({
    this.notificaciones = const [],
    this.isLoading = false,
    this.error,
  });

  NotificacionesState copyWith({
    List<Notificacion>? notificaciones,
    bool? isLoading,
    String? error,
  }) {
    return NotificacionesState(
      notificaciones: notificaciones ?? this.notificaciones,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get unreadCount =>
      notificaciones.where((n) => !n.leida).length;
}

/// Repository providers
final notificacionesRemoteDataSourceProvider =
    Provider<NotificacionesRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificacionesRemoteDataSource(dioClient);
});

final notificacionesRepositoryProvider = Provider<NotificacionesRepository>((ref) {
  final remoteDataSource = ref.watch(notificacionesRemoteDataSourceProvider);
  return NotificacionesRepositoryImpl(remoteDataSource);
});

/// Notificaciones notifier
class NotificacionesNotifier extends StateNotifier<NotificacionesState> {
  final NotificacionesRepository _repository;

  NotificacionesNotifier(this._repository) : super(const NotificacionesState());

  /// Load notificaciones
  Future<void> loadNotificaciones() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getNotificaciones();

    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
      (notificaciones) {
        state = state.copyWith(
          notificaciones: notificaciones,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Mark notificacion as read
  Future<bool> marcarLeida(String id) async {
    final result = await _repository.marcarLeida(id);

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (notificacion) {
        final updatedList = state.notificaciones.map((n) {
          return n.id == id ? notificacion : n;
        }).toList();

        state = state.copyWith(notificaciones: updatedList);
        return true;
      },
    );
  }

  /// Mark all as read
  Future<bool> marcarTodasLeidas() async {
    final result = await _repository.marcarTodasLeidas();

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (_) {
        final updatedList = state.notificaciones
            .map((n) => n.copyWith(leida: true))
            .toList();

        state = state.copyWith(notificaciones: updatedList);
        return true;
      },
    );
  }

  /// Delete notificacion
  Future<bool> deleteNotificacion(String id) async {
    final result = await _repository.deleteNotificacion(id);

    return result.fold(
      (error) {
        state = state.copyWith(error: error.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          notificaciones: state.notificaciones.where((n) => n.id != id).toList(),
        );
        return true;
      },
    );
  }

  /// Refresh
  Future<void> refresh() async {
    await loadNotificaciones();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Notificaciones provider
final notificacionesProvider =
    StateNotifierProvider<NotificacionesNotifier, NotificacionesState>((ref) {
  final repository = ref.watch(notificacionesRepositoryProvider);
  return NotificacionesNotifier(repository);
});
