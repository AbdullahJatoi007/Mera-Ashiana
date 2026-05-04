import 'package:dio/dio.dart';
import 'package:mera_ashiana/core/network/api_client.dart';

import 'package:mera_ashiana/data/services/auth/secure_storage_service.dart';

import '../../../core/network/endpoints.dart';

class AuthService {
  // ───────────── SEND OTP ─────────────
  static Future<void> sendOtp({
    required String username,
    required String email,
    required String password,
    required String type,
  }) async {
    await ApiClient.post(
      // Fixed: Changed from sendRegisterOtp to sendOtp to match your Endpoints class
      Endpoints.sendOtp,
      data: {
        'username': username.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'type': type,
      },
    );
  }

  // ───────────── REGISTER ─────────────
  static Future<void> verifyOtpAndRegister({
    required String email,
    required String otp,
  }) async {
    final res = await ApiClient.post(
      Endpoints.register,
      data: {'email': email.trim().toLowerCase(), 'otp': otp},
    );

    final accessToken = res.data['accessToken'] ?? res.data['token'];
    if (accessToken != null) {
      await SecureStorageService.write(key: 'access_token', value: accessToken);
    }

    final refreshToken = res.data['refreshToken'];
    if (refreshToken != null) {
      await SecureStorageService.write(
        key: 'refresh_token',
        value: refreshToken,
      );
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

  // ───────────── LOGIN ─────────────
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.post(
      Endpoints.login,
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );

    final accessToken = res.data['accessToken'] ?? res.data['token'];
    if (accessToken != null) {
      await SecureStorageService.write(key: 'access_token', value: accessToken);
    }

    final refreshToken = res.data['refreshToken'];
    if (refreshToken != null) {
      await SecureStorageService.write(
        key: 'refresh_token',
        value: refreshToken,
      );
    }
  }
}
