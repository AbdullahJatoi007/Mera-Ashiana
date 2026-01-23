import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_config.dart';
import 'auth_exceptions.dart';
import 'secure_storage_service.dart';
import 'rate_limiter.dart';

class AuthService {
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final cookie = await SecureStorageService.read(
        key: AuthConfig.authCookieKey,
      );
      if (cookie != null) {
        headers['Cookie'] = cookie;
      }
    }

    return headers;
  }

  static Future<http.Response> _makeRequest({
    required Future<http.Response> Function() request,
    int retryCount = 0,
  }) async {
    try {
      final response = await request().timeout(AuthConfig.connectionTimeout);
      return response;
    } on SocketException {
      if (retryCount < AuthConfig.maxRetries) {
        await Future.delayed(AuthConfig.retryDelay);
        return _makeRequest(request: request, retryCount: retryCount + 1);
      }
      throw NetworkException(
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      throw NetworkException('Network error occurred. Please try again.');
    } on FormatException {
      throw NetworkException('Invalid response from server.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException('Connection failed. Please try again.');
    }
  }

  static AuthException _parseError(
    http.Response response,
    String defaultMessage,
  ) {
    try {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? data['error'] ?? defaultMessage;

      if (response.statusCode == 401) {
        return UnauthorizedException(message);
      }

      return AuthException(message, statusCode: response.statusCode);
    } catch (e) {
      return AuthException(defaultMessage, statusCode: response.statusCode);
    }
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String repassword,
    required String type,
  }) async {
    if (username.trim().isEmpty) {
      throw ValidationException('Username is required');
    }

    if (username.trim().length < 3) {
      throw ValidationException('Username must be at least 3 characters');
    }

    final backendType = type == "user" ? "single_user" : "agent";

    // FIXED: Added 'async' before the '=>'
    final response = await _makeRequest(
      request: () async => http.post(
        Uri.parse('${AuthConfig.baseUrl}/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'repassword': repassword,
          'type': backendType,
        }),
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        final cookie = rawCookie.split(';').first;
        await SecureStorageService.write(
          key: AuthConfig.authCookieKey,
          value: cookie,
        );
      }

      final data = jsonDecode(response.body);
      return data;
    }

    throw _parseError(response, 'Registration failed. Please try again.');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await RateLimiter.checkRateLimit();

    if (email.trim().isEmpty) {
      throw ValidationException('Email is required');
    }

    if (password.isEmpty) {
      throw ValidationException('Password is required');
    }

    try {
      // FIXED: Added 'async' before the '=>'
      final response = await _makeRequest(
        request: () async => http.post(
          Uri.parse('${AuthConfig.baseUrl}/login'),
          headers: await _getHeaders(),
          body: jsonEncode({
            'email': email.trim().toLowerCase(),
            'password': password,
          }),
        ),
      );

      if (response.statusCode == 200) {
        await RateLimiter.resetAttempts();

        final rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          final cookie = rawCookie.split(';').first;
          await SecureStorageService.write(
            key: AuthConfig.authCookieKey,
            value: cookie,
          );
        }

        final data = jsonDecode(response.body);
        return data;
      }

      await RateLimiter.recordAttempt();
      throw _parseError(
        response,
        'Login failed. Please check your credentials.',
      );
    } catch (e) {
      if (e is! RateLimitException) {
        await RateLimiter.recordAttempt();
      }
      rethrow;
    }
  }

  static Future<String?> getAuthCookie() async {
    return await SecureStorageService.read(key: AuthConfig.authCookieKey);
  }

  static Future<bool> isAuthenticated() async {
    final cookie = await getAuthCookie();
    return cookie != null && cookie.isNotEmpty;
  }

  static Future<void> logout() async {
    await SecureStorageService.deleteAll();
    await RateLimiter.resetAttempts();
  }

  static Future<void> handleUnauthorized() async {
    await logout();
  }
}
