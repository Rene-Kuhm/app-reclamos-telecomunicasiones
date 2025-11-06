/// Application-wide configuration
class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Hive Box Names
  static const String reclamosBoxName = 'reclamos_box';
  static const String notificacionesBoxName = 'notificaciones_box';
  static const String settingsBoxName = 'settings_box';

  // OneSignal Configuration
  static const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx'
  ];

  // UI Configuration
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration splashScreenDuration = Duration(seconds: 2);

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration shortCacheExpiration = Duration(minutes: 5);

  // App Information
  static const String appName = 'Reclamos Telco';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'soporte@reclamostelco.com';
  static const String privacyPolicyUrl = 'https://reclamostelco.com/privacy';
  static const String termsOfServiceUrl = 'https://reclamostelco.com/terms';
}
