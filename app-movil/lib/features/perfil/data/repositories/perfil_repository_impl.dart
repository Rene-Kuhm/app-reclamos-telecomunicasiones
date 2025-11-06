import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../datasources/perfil_remote_datasource.dart';
import '../models/update_profile_request.dart';
import '../models/change_password_request.dart';

/// Perfil repository implementation
class PerfilRepositoryImpl implements PerfilRepository {
  final PerfilRemoteDataSource _remoteDataSource;

  PerfilRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<ApiError, User>> getProfile() async {
    try {
      final model = await _remoteDataSource.getProfile();
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ApiError.unknown(error.toString()));
    }
  }

  @override
  Future<Either<ApiError, User>> updateProfile({
    String? nombre,
    String? telefono,
    String? direccion,
    String? dni,
  }) async {
    try {
      final request = UpdateProfileRequest(
        nombre: nombre,
        telefono: telefono,
        direccion: direccion,
        dni: dni,
      );

      final model = await _remoteDataSource.updateProfile(request);
      return Right(model.toEntity());
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ApiError.unknown(error.toString()));
    }
  }

  @override
  Future<Either<ApiError, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await _remoteDataSource.changePassword(request);
      return const Right(null);
    } on ApiError catch (error) {
      return Left(error);
    } catch (error) {
      return Left(ApiError.unknown(error.toString()));
    }
  }
}
