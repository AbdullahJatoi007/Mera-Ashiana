import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/helpers/internet_helper.dart';
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
    _dio ??= _initDio();
    return _dio!;
  }
  static void init() {
    dio; // forces Dio initialization safely
  }


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

    dio.options.extra['withCredentials'] = true;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cookie = await SecureStorageService.read(
            key: AuthConfig.authCookieKey,
          );

          if (cookie != null) {
            options.headers['Cookie'] = cookie;
          }

          if (kDebugMode) {
            debugPrint('[API REQUEST] ${options.method} ${options.uri}');
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[API RESPONSE] ${response.statusCode}');
          }
          handler.next(response);
        },

        onError: (DioException e, handler) async {
          if (kDebugMode) {
            debugPrint('[API ERROR] ${e.type}');
          }

          // 🚫 No Internet
          final hasInternet = await InternetHelper.hasInternetConnection();
          if (!hasInternet) {
            handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: NetworkException(
                  'No internet connection. Please check your network and try again.',
                ),
                type: DioExceptionType.unknown,
              ),
            );
            return;
          }

          // ⏱ Timeout
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: NetworkException('Request timed out. Please try again.'),
                type: e.type,
              ),
            );
            return;
          }

          // 🧱 Server error with response
          if (e.response != null) {
            final data = e.response?.data;
            final message = data is Map && data['message'] != null
                ? data['message'].toString()
                : 'Service is currently unavailable. Please try again later.';

            handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                error: NetworkException(message),
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }

          // ❓ Unknown fallback
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: NetworkException(
                'Unexpected error occurred. Please try again.',
              ),
              type: DioExceptionType.unknown,
            ),
          );
        },
      ),
    );

    return dio;
  }

  // ---------- HTTP METHODS ----------

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
