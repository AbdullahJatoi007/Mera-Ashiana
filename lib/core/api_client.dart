import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/services/auth/secure_storage_service.dart';
import 'package:mera_ashiana/network/endpoints.dart';

import '../services/auth/auth_service.dart';

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
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Check if error is 401 (Unauthorized) and specifically due to token expiry
          if (e.response?.statusCode == 401) {
            final errorMsg = e.response?.data['error']?.toString().toLowerCase() ?? '';

            if (errorMsg.contains('expired') || errorMsg.contains('invalid')) {
              try {
                // 1. Attempt to refresh the token
                final success = await _refreshToken();

                if (success) {
                  // 2. If success, retry the original request with the new token
                  final token = await SecureStorageService.read(key: 'access_token');
                  e.requestOptions.headers['Authorization'] = 'Bearer $token';

                  final response = await dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                }
              } catch (refreshError) {
                // If refresh fails, log the user out
                await AuthService.logout();
              }
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
      // NOTE: Your backend expects the refresh token in a cookie.
      // Since we aren't using a CookieJar yet, we must ensure the backend
      // also accepts it or we must manually set the Cookie header.
      final response = await Dio().post(
        "${Endpoints.apiBase}/auth/session/refresh",
        options: Options(
          headers: {
            // If your backend only uses cookies, we have to pass it manually here
            // This assumes you saved the refresh token during login
            'Cookie': await SecureStorageService.read(key: 'refresh_cookie') ?? '',
          },
        ),
      );

      final newToken = response.data['accessToken'];
      if (newToken != null) {
        await SecureStorageService.write(key: 'access_token', value: newToken);
        final newCookies = response.headers['set-cookie'];
        return true;
      }
    } catch (e) {
      debugPrint("Token Refresh Failed: $e");
    }
    return false;
  }

  static Future<Response> post(String path, {dynamic data}) => dio.post(path, data: data);
  static Future<Response> get(String path) => dio.get(path);
  static Future<Response> delete(String path, {dynamic data}) => dio.delete(path, data: data);
}