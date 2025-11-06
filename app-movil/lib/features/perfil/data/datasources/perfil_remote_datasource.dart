import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/update_profile_request.dart';
import '../models/change_password_request.dart';

/// Perfil remote data source
class PerfilRemoteDataSource {
  final DioClient _dioClient;

  PerfilRemoteDataSource(this._dioClient);

  /// Get current user profile
  Future<UserModel> getProfile() async {
    final response = await _dioClient.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Update profile
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    final response = await _dioClient.patch(
      ApiEndpoints.updateProfile,
      data: request.toJson(),
    );
    return UserModel.fromJson(response.data['data'] ?? response.data);
  }

  /// Change password
  Future<void> changePassword(ChangePasswordRequest request) async {
    await _dioClient.post(
      ApiEndpoints.changePassword,
      data: request.toJson(),
    );
  }
}
