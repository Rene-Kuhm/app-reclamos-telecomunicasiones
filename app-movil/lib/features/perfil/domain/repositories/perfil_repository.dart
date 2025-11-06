import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../../../auth/domain/entities/user.dart';

/// Perfil repository interface
abstract class PerfilRepository {
  /// Get current user profile
  Future<Either<ApiError, User>> getProfile();

  /// Update profile
  Future<Either<ApiError, User>> updateProfile({
    String? nombre,
    String? telefono,
    String? direccion,
    String? dni,
  });

  /// Change password
  Future<Either<ApiError, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
