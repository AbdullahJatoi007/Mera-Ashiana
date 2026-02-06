import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:mera_ashiana/services/auth/secure_storage_service.dart';
import 'package:mera_ashiana/services/auth/auth_config.dart';
import 'package:mera_ashiana/network/endpoints.dart';

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

class ApiClient {
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) init();
    return _dio!;
  }

  static void init() {
    if (_dio != null) return;

    _dio = Dio(
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

    _dio!.options.extra['withCredentials'] = true;

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cookie = await SecureStorageService.read(
            key: AuthConfig.authCookieKey,
          );

          if (cookie != null) {
            options.headers['Cookie'] = cookie;
          }

          if (kDebugMode) {
            print("[API REQUEST] ${options.method} ${options.uri}");
            print("[API HEADERS] ${options.headers}");
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("[API RESPONSE] ${response.statusCode}");
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            print("[API ERROR BODY] ${e.response?.data}");
          }

          handler.reject(e);
        },
      ),
    );
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => dio.get(path, queryParameters: queryParameters);

  static Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);

  static Future<Response> put(String path, {dynamic data}) =>
      dio.put(path, data: data);

  static Future<Response> delete(String path, {dynamic data}) =>
      dio.delete(path, data: data);
}
