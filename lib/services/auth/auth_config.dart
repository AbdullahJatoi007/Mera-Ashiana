class AuthConfig {
  // CRITICAL: Use HTTPS in production - HTTP violates Google Play policy
  static const String baseUrl = "http://api.staging.mera-ashiana.com/api";

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Rate limiting
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(seconds: 30);

  // Storage keys
  static const String authCookieKey = 'auth_cookie';
  static const String loginAttemptsKey = 'login_attempts';
  static const String lastAttemptKey = 'last_attempt_timestamp';

  // ✅ ADD THIS: Security/URL Validation
  static const List<String> allowedDomains = [
    'mera-ashiana.com',
    'staging.mera-ashiana.com',
  ];
}
