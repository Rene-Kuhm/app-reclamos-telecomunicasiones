import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

/// Auth remote data source
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  /// Login
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  /// Register
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  /// Refresh token
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    return {
      'accessToken': response.data['accessToken'] as String,
      'refreshToken': response.data['refreshToken'] as String,
    };
  }

  /// Logout
  Future<void> logout() async {
    await _dioClient.post(ApiEndpoints.logout);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dioClient.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data);
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    await _dioClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  /// Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dioClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );
  }
}
