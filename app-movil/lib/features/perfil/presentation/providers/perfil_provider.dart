import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/perfil_remote_datasource.dart';
import '../../data/repositories/perfil_repository_impl.dart';
import '../../domain/repositories/perfil_repository.dart';

/// Perfil state
class PerfilState {
  final User? user;
  final bool isLoading;
  final String? error;

  const PerfilState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  PerfilState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return PerfilState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Repository providers
final perfilRemoteDataSourceProvider = Provider<PerfilRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PerfilRemoteDataSource(dioClient);
});

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  final remoteDataSource = ref.watch(perfilRemoteDataSourceProvider);
  return PerfilRepositoryImpl(remoteDataSource);
});

/// Perfil notifier
class PerfilNotifier extends StateNotifier<PerfilState> {
  final PerfilRepository _repository;
  final Ref _ref;

  PerfilNotifier(this._repository, this._ref) : super(const PerfilState());

  /// Load profile
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getProfile();

    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Update profile
  Future<bool> updateProfile({
    String? nombre,
    String? telefono,
    String? direccion,
    String? dni,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.updateProfile(
      nombre: nombre,
      telefono: telefono,
      direccion: direccion,
      dni: dni,
    );

    return result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          error: null,
        );
        // Update auth provider user as well
        _ref.read(authProvider.notifier).refreshUser();
        return true;
      },
    );
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Perfil provider
final perfilProvider = StateNotifierProvider<PerfilNotifier, PerfilState>((ref) {
  final repository = ref.watch(perfilRepositoryProvider);
  return PerfilNotifier(repository, ref);
});
