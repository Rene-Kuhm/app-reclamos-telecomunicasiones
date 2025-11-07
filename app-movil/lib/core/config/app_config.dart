/// Environment enum
enum Environment {
  development,
  staging,
  production,
}

/// Application-wide configuration with environment support
class AppConfig {
  // Current environment - Change this to switch environments
  static const Environment _currentEnvironment = Environment.development;

  // Environment getter
  static String get environment {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }

  // API Configuration by environment
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.reclamostelco.com/api/v1';
      case Environment.production:
        return 'https://api.reclamostelco.com/api/v1';
    }
  }

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

  // OneSignal Configuration by environment
  static String get oneSignalAppId {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'YOUR_DEV_ONESIGNAL_APP_ID';
      case Environment.staging:
        return 'YOUR_STAGING_ONESIGNAL_APP_ID';
      case Environment.production:
        return 'YOUR_PROD_ONESIGNAL_APP_ID';
    }
  }

  // Debug/Logging configuration
  static bool get isDebugMode {
    return _currentEnvironment == Environment.development;
  }

  static bool get enableLogging {
    return _currentEnvironment != Environment.production;
  }

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
  static String get supportEmail {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'dev-soporte@reclamostelco.com';
      case Environment.staging:
        return 'staging-soporte@reclamostelco.com';
      case Environment.production:
        return 'soporte@reclamostelco.com';
    }
  }

  static const String privacyPolicyUrl = 'https://reclamostelco.com/privacy';
  static const String termsOfServiceUrl = 'https://reclamostelco.com/terms';

  // Feature flags by environment
  static bool get enableAnalytics {
    return _currentEnvironment == Environment.production;
  }

  static bool get enableCrashReporting {
    return _currentEnvironment != Environment.development;
  }
}
