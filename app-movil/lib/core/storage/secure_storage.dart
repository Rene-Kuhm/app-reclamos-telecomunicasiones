import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Secure storage for sensitive data (tokens, passwords, etc.)
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  // Token Management
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConfig.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConfig.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConfig.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConfig.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
  }

  // User Data Management
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConfig.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConfig.userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: AppConfig.userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: AppConfig.userEmailKey);
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Generic write
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Generic read
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Generic delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Read all values
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}
