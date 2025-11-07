import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth state
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Providers
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dioClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(remoteDataSource, secureStorage);
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            error: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
            isLoading: false,
            error: null,
          );
        },
      );
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  /// Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        print('[AuthProvider] Login failed: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (user) {
        print('[AuthProvider] Login successful - User: ${user.nombre}, Email: ${user.email}');
        print('[AuthProvider] Setting isAuthenticated = true');
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          error: null,
        );
        print('[AuthProvider] State updated - isAuthenticated: ${state.isAuthenticated}');
        return true;
      },
    );
  }

  /// Register
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
    String? dni,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.register(
      nombre: nombre,
      email: email,
      password: password,
      telefono: telefono,
      direccion: direccion,
      dni: dni,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    await _authRepository.logout();

    state = const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (user) {
        state = state.copyWith(user: user, error: null);
      },
    );
  }

  /// Forgot password
  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.forgotPassword(email: email);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.resetPassword(
      token: token,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
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

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
