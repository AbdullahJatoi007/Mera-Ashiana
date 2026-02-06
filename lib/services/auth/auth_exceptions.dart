class AuthException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  AuthException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AuthException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class ValidationException extends AuthException {
  ValidationException(String message)
    : super(message, code: 'VALIDATION_ERROR');
}

class RateLimitException extends AuthException {
  final DateTime retryAfter;

  RateLimitException(String message, this.retryAfter)
    : super(message, code: 'RATE_LIMIT');
}

class UnauthorizedException extends AuthException {
  UnauthorizedException(String message)
    : super(message, code: 'UNAUTHORIZED', statusCode: 401);
}
