class EnvironmentConfig {
  static const String appName = 'Appointly';
  static const String appVersion = '1.0.0';

  static const String apiBaseUrl = 'https://vcare.integration25.com/api';
  static const String alternativeApiBaseUrl = 'https://vcare.integration25.com';
  static const String testApiBaseUrl = 'http://vcare.integration25.com/api';
  static const int apiTimeout = 30000;

  static const bool enableLogging = true;
  static const bool enableDebugLogs = true;
  static const bool enableErrorLogs = true;

  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  static const bool isDevelopment = true;
  static const bool isProduction = false;
  static const bool isStaging = false;

  static const int cacheTimeout = 300;
  static const int maxCacheSize = 50;

  static const bool enableSSL = true;
  static const bool enableCertificatePinning = false;
}
