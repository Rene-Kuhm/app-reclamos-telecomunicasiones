import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, User>> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
    String? dni,
  });

  /// Refresh access token
  Future<Either<Failure, void>> refreshToken();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Get current user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}
