import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/data/services/auth/secure_storage_service.dart';
import 'package:mera_ashiana/core/network/endpoints.dart';

// FIX 1: Import LogoutService instead of AuthService to prevent infinite network loops
import 'package:mera_ashiana/data/services/logout_service.dart';

import 'endpoints.dart';

class ApiClient {
  static Dio? _dio;

  static Dio get dio => _dio ??= _initDio();

  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.apiBase,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.read(key: 'access_token');

          // 🚨 LOGGING THE REQUEST
          debugPrint('🌐 [API REQUEST] ${options.method} ${options.uri}');
          debugPrint('🔑 [API TOKEN ATTACHED?] ${token != null ? 'YES' : 'NO'}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 🚨 LOGGING THE SUCCESSFUL RESPONSE
          debugPrint('✅ [API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          debugPrint('📦 [API DATA] ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // 🚨 LOGGING THE ERROR
          debugPrint('❌ [API ERROR] ${e.response?.statusCode} ${e.requestOptions.path}');
          debugPrint('❌ [API ERROR MSG] ${e.message}');
          debugPrint('❌ [API ERROR DATA] ${e.response?.data}');

          if (e.response?.statusCode == 401) {
            debugPrint('🔄 [API REFRESH] Attempting to refresh token...');
            try {
              final success = await _refreshToken();
              if (success) {
                debugPrint('✅ [API REFRESH] Success! Retrying original request.');
                final token = await SecureStorageService.read(key: 'access_token');
                e.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } else {
                debugPrint('❌ [API REFRESH] Failed. Logging out.');
                await LogoutService.logout();
              }
            } catch (refreshError) {
              debugPrint('🚨 [API REFRESH EXCEPTION] $refreshError');
              await LogoutService.logout();
            }
          }
          return handler.next(e);
        },
      ),
    );
    return dio;
  }

  static Future<bool> _refreshToken() async {
    try {
      final storedRefreshToken = await SecureStorageService.read(
        key: 'refresh_token',
      );
      if (storedRefreshToken == null) return false;

      // Using a NEW Dio() instance here is correct! It prevents interceptor infinite loops.
      final response = await Dio().post(
        Endpoints.refreshToken,
        data: {'refreshToken': storedRefreshToken},
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response
          .data['refreshToken']; // Might be null if backend doesn't rotate it

      if (newAccessToken != null) {
        await SecureStorageService.write(
          key: 'access_token',
          value: newAccessToken,
        );

        // Only overwrite refresh token if the backend provided a new one
        if (newRefreshToken != null) {
          await SecureStorageService.write(
            key: 'refresh_token',
            value: newRefreshToken,
          );
        }
        return true;
      }
    } catch (e) {
      debugPrint("Token Refresh Failed: $e");
    }
    return false;
  }

  // Helper Wrappers
  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => dio.post(path, data: data, queryParameters: queryParameters);

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => dio.get(path, queryParameters: queryParameters);

  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => dio.delete(path, data: data, queryParameters: queryParameters);
}
