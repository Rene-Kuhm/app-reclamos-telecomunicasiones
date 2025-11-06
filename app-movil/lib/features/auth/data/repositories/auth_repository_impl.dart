import 'package:dartz/dartz.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _remoteDataSource.login(request);

      // Save tokens
      await _secureStorage.saveAccessToken(response.accessToken);
      await _secureStorage.saveRefreshToken(response.refreshToken);
      await _secureStorage.saveUserId(response.usuario.id);
      await _secureStorage.saveUserEmail(response.usuario.email);

      return Right(response.usuario.toEntity());
    } on ApiException catch (e) {
      return Left(ErrorHandler.exceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
    String? dni,
  }) async {
    try {
      final request = RegisterRequest(
        nombre: nombre,
        email: email,
        password: password,
        telefono: telefono,
        direccion: direccion,
        dni: dni,
      );

      final response = await _remoteDataSource.register(request);

      // Save tokens
      await _secureStorage.saveAccessToken(response.accessToken);
      await _secureStorage.saveRefreshToken(response.refreshToken);
      await _secureStorage.saveUserId(response.usuario.id);
      await _secureStorage.saveUserEmail(response.usuario.email);

      return Right(response.usuario.toEntity());
    } on ApiException catch (e) {
      return Left(ErrorHandler.exceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null) {
        return const Left(UnauthorizedFailure('No hay token de refresco'));
      }

      final tokens = await _remoteDataSource.refreshToken(refreshToken);

      // Save new tokens
      await _secureStorage.saveAccessToken(tokens['accessToken']!);
      await _secureStorage.saveRefreshToken(tokens['refreshToken']!);

      return const Right(null);
    } on ApiException catch (e) {
      // Clear tokens on refresh failure
      await _secureStorage.clearTokens();
      return Left(ErrorHandler.exceptionToFailure(e));
    } catch (e) {
      await _secureStorage.clearTokens();
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _secureStorage.clearAll();
      return const Right(null);
    } on ApiException catch (e) {
      // Clear tokens even if logout fails
      await _secureStorage.clearAll();
      return Left(ErrorHandler.exceptionToFailure(e));
    } catch (e) {
      await _secureStorage.clearAll();
      return const Right(null); // Don't fail logout on error
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ErrorHandler.exceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on ApiException catch (e) {
      return Left(ErrorHandler.exceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _secureStorage.isLoggedIn();
  }
}
