import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/services/auth/secure_storage_service.dart';
import 'package:mera_ashiana/network/endpoints.dart';

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
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint('[API] ${options.method} ${options.uri}');
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) {
          final msg = e.response?.data is Map
              ? (e.response?.data['error'] ??
              e.response?.data['message'])
              : 'Connection error';

          if (kDebugMode) {
            debugPrint('[API ERROR] $msg');
          }

          return handler.next(e.copyWith(message: msg.toString()));
        },
      ),
    );

    return dio;
  }

  static Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);

  static Future<Response> get(String path) =>
      dio.get(path);

  // ✅ ADD THIS
  static Future<Response> delete(String path, {dynamic data}) =>
      dio.delete(path, data: data);
}