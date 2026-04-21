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
          if (e.response?.statusCode == 401) {
            final errorMsg = e.response?.data['error']?.toString().toLowerCase() ?? '';

            if (errorMsg.contains('expired') || errorMsg.contains('invalid')) {
              try {
                final success = await _refreshToken();
                if (success) {
                  final token = await SecureStorageService.read(key: 'access_token');
                  e.requestOptions.headers['Authorization'] = 'Bearer $token';

                  final response = await dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                }
              } catch (refreshError) {
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
      final storedRefreshToken = await SecureStorageService.read(key: 'refresh_token');
      if (storedRefreshToken == null) return false;

      final response = await Dio().post(
        Endpoints.refreshToken,
        data: {'refreshToken': storedRefreshToken},
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];
      if (newAccessToken != null) {
        await SecureStorageService.write(key: 'access_token', value: newAccessToken);
        if (newRefreshToken != null) {
          await SecureStorageService.write(key: 'refresh_token', value: newRefreshToken);
        }
        return true;
      }
    } catch (e) {
      debugPrint("Token Refresh Failed: $e");
    }
    return false;
  }

  // Helper Wrappers
  static Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      dio.post(path, data: data, queryParameters: queryParameters);

  // ✅ UPDATED: Added the optional queryParameters parameter
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get(path, queryParameters: queryParameters);

  static Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      dio.delete(path, data: data, queryParameters: queryParameters);
}