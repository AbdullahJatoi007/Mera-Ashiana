import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/core/network/api_client.dart';
import 'package:mera_ashiana/data/services/auth/secure_storage_service.dart';
import '../../../core/network/endpoints.dart';

class AuthService {
  // ───────────── ERROR HELPER ─────────────
  // Pulls the backend's actual error message out of a DioException so the
  // toast shows e.g. "Phone number is required." instead of Dio's generic
  // multi-line "status code of 400..." paragraph.
  static String _serverError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return (data['error'] ?? data['message'] ?? 'Request failed')
            .toString();
      }
      if (data is String && data.isNotEmpty) return data;
      return e.message ?? 'Network error. Please try again.';
    }
    return e.toString();
  }

  // ───────────── SEND OTP ─────────────
  static Future<void> sendOtp({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String type,
  }) async {
    final payload = {
      'username': username.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
      'type': type,
    };
    debugPrint('📤 [SEND-OTP] payload: $payload');
    try {
      await ApiClient.post(Endpoints.sendOtp, data: payload);
    } on DioException catch (e) {
      debugPrint('❌ [SEND-OTP] ${e.response?.statusCode}: ${e.response?.data}');
      throw Exception(_serverError(e));
    }
  }

  // ───────────── REGISTER ─────────────
  static Future<void> verifyOtpAndRegister({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await ApiClient.post(
        Endpoints.register,
        data: {'email': email.trim().toLowerCase(), 'otp': otp},
      );

      final accessToken = res.data['accessToken'] ?? res.data['token'];
      if (accessToken != null) {
        await SecureStorageService.write(
          key: 'access_token',
          value: accessToken,
        );
      }

      final refreshToken = res.data['refreshToken'];
      if (refreshToken != null) {
        await SecureStorageService.write(
          key: 'refresh_token',
          value: refreshToken,
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [REGISTER] ${e.response?.statusCode}: ${e.response?.data}');
      throw Exception(_serverError(e));
    }
  }

  // ───────────── LOGIN ─────────────
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await ApiClient.post(
        Endpoints.login,
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );

      final accessToken = res.data['accessToken'] ?? res.data['token'];
      if (accessToken != null) {
        await SecureStorageService.write(
          key: 'access_token',
          value: accessToken,
        );
      }

      final refreshToken = res.data['refreshToken'];
      if (refreshToken != null) {
        await SecureStorageService.write(
          key: 'refresh_token',
          value: refreshToken,
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [LOGIN] ${e.response?.statusCode}: ${e.response?.data}');
      throw Exception(_serverError(e));
    }
  }

  // ───────────── FORGOT PASSWORD: SEND OTP ─────────────
  // Backend: POST /forgot-password/send-otp | body { email }
  // Always returns 200 (doesn't leak whether the email exists).
  static Future<void> sendForgotPasswordOtp({required String email}) async {
    try {
      await ApiClient.post(
        Endpoints.forgotPasswordSendOtp,
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (e) {
      debugPrint(
        '❌ [FORGOT-PW SEND-OTP] ${e.response?.statusCode}: ${e.response?.data}',
      );
      throw Exception(_serverError(e));
    }
  }

  // ───────────── FORGOT PASSWORD: RESET ─────────────
  // Backend: POST /forgot-password/reset | body { email, otp, newPassword }
  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      await ApiClient.post(
        Endpoints.forgotPasswordReset,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'newPassword': password,
        },
      );
    } on DioException catch (e) {
      debugPrint(
        '❌ [FORGOT-PW RESET] ${e.response?.statusCode}: ${e.response?.data}',
      );
      throw Exception(_serverError(e));
    }
  }

  // ───────────── LOGOUT ─────────────
  static Future<void> logout() async {
    try {
      final refreshToken = await SecureStorageService.read(
        key: 'refresh_token',
      );
      final accessToken = await SecureStorageService.read(key: 'access_token');

      // 🚨 FIX: Use a raw Dio instance!
      // This bypasses the ApiClient interceptor queue and prevents deadly infinite loops during logout.
      if (refreshToken != null) {
        await Dio().delete(
          Endpoints.logout,
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      }
    } catch (_) {
      // Silent fail on backend logout to ensure local wipe still happens
    }

    await SecureStorageService.delete(key: 'access_token');
    await SecureStorageService.delete(key: 'refresh_token');
  }
}
