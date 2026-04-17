import 'package:mera_ashiana/core/api_client.dart';
import 'package:mera_ashiana/network/endpoints.dart';
import 'package:mera_ashiana/services/auth/secure_storage_service.dart';

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

    // Note: Ensure the key 'accessToken' matches your backend response exactly
    final token = res.data['accessToken'] ?? res.data['token'];
    if (token != null) {
      await SecureStorageService.write(key: 'access_token', value: token);
    }
  }

  // ───────────── LOGOUT ─────────────
  static Future<void> logout() async {
    try {
      // Uses Endpoints.logout -> "$apiBase/auth/session/logout"
      await ApiClient.post(Endpoints.logout);
    } catch (_) {
      // Silent fail on backend logout to ensure local wipe still happens
    }

    // Always clear local storage regardless of backend response
    await SecureStorageService.delete(key: 'access_token');
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

    // 1. Save Access Token
    final token = res.data['accessToken'] ?? res.data['token'];
    if (token != null) {
      await SecureStorageService.write(key: 'access_token', value: token);
    }

    // 2. Save Refresh Cookie (Crucial for the refresh logic)
    final cookies = res.headers['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      // We store the whole cookie string to send back later
      await SecureStorageService.write(
        key: 'refresh_cookie',
        value: cookies.first,
      );
    }
  }
}
