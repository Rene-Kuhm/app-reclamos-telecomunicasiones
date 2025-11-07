import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_movil/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_movil/features/auth/domain/entities/user.dart';

void main() {
  group('AuthProvider', () {
    test('initial state should be unauthenticated', () {
      final container = ProviderContainer();
      final authState = container.read(authProvider);

      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, null);

      container.dispose();
    });

    test('should update state on copyWith', () {
      final initialState = const AuthState();
      final user = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      final newState = initialState.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );

      expect(newState.isAuthenticated, true);
      expect(newState.user, user);
      expect(newState.isLoading, false);
      expect(newState.error, null);
    });

    test('should preserve previous values when not provided in copyWith', () {
      final user = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      final state = AuthState(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        error: null,
      );

      final newState = state.copyWith(isLoading: true);

      expect(newState.isAuthenticated, true);
      expect(newState.user, user);
      expect(newState.isLoading, true);
      expect(newState.error, null);
    });

    test('should clear error when error is set to null in copyWith', () {
      final state = const AuthState(
        isAuthenticated: false,
        error: 'Some error',
      );

      final newState = state.copyWith(error: null);

      expect(newState.error, null);
    });
  });

  group('AuthState', () {
    test('should create state with default values', () {
      const state = AuthState();

      expect(state.isAuthenticated, false);
      expect(state.user, null);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('should create state with provided values', () {
      final user = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      final state = AuthState(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        error: 'Test error',
      );

      expect(state.isAuthenticated, true);
      expect(state.user, user);
      expect(state.isLoading, false);
      expect(state.error, 'Test error');
    });

    test('different states should not be equal', () {
      final user1 = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      final user2 = User(
        id: '2',
        nombre: 'Jane',
        apellido: 'Smith',
        email: 'jane@example.com',
        rol: 'TECNICO',
        activo: true,
      );

      final state1 = AuthState(isAuthenticated: true, user: user1);
      final state2 = AuthState(isAuthenticated: true, user: user2);
      final state3 = AuthState(isAuthenticated: false, user: null);

      expect(state1 == state2, false);
      expect(state1 == state3, false);
    });
  });
}
