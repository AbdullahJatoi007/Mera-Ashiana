class AuthConfig {
  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Rate limiting for login
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 1);

  // Secure storage keys
  static const String authCookieKey = 'auth_cookie';
  static const String loginAttemptsKey = 'login_attempts';
  static const String lastAttemptKey = 'last_attempt_timestamp';

  // Allowed domains for API requests
  static const List<String> allowedDomains = [
    'mera-ashiana.com',
    'api.mera-ashiana.com', // production
    'api-staging.mera-ashiana.com',
  ];
}
