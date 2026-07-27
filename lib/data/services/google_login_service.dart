import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mera_ashiana/core/network/api_client.dart';
import '../../core/config/google_auth_config.dart';
import '../../core/network/endpoints.dart';
import 'auth/secure_storage_service.dart';

/// Result of phase 1: Google identity + mobile login attempt.
class GoogleAuthResult {
  final bool loggedIn; // existing user — app tokens already stored
  final bool needsRegistration; // new user — collect role + phone next
  final String? idToken; // Google ID token, held for registration completion
  final String? email;
  final String? name;

  const GoogleAuthResult({
    this.loggedIn = false,
    this.needsRegistration = false,
    this.idToken,
    this.email,
    this.name,
  });
}

class GoogleLoginService {
  static bool _initialized = false;

  static Future<void> _ensureInit() async {
    if (_initialized) return;
    // serverClientId = the WEB client. Google mints the ID token with this as
    // `aud`, which is exactly what the backend checks against GOOGLE_CLIENT_ID.
    await GoogleSignIn.instance.initialize(
      serverClientId: GoogleAuthConfig.webClientId,
    );
    _initialized = true;
  }

  /// Machine-readable backend error code. Branch on this, never on messages.
  static String? _errorCode(DioException e) {
    final data = e.response?.data;
    return data is Map ? data['code']?.toString() : null;
  }

  static String _serverError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return (data['error'] ?? data['message'] ?? 'Google sign-in failed.')
            .toString();
      }
      if (data is String && data.isNotEmpty) return data;
      return e.message ?? 'Network error. Please try again.';
    }
    return e.toString();
  }

  /// Phase 1: pick account → Google ID token → mobile login.
  ///
  /// `loggedIn` on success, `needsRegistration` when the backend has no account
  /// yet, or an empty result when the user dismissed the picker.
  static Future<GoogleAuthResult> startGoogleSignIn() async {
    await _ensureInit();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleAuthResult();
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google did not return an ID token. Check the Android OAuth client '
        '(package name + SHA-1) and GoogleAuthConfig.webClientId.',
      );
    }

    try {
      final res = await ApiClient.post(
        Endpoints.googleAuth,
        data: {'idToken': idToken, 'mode': 'login'},
      );
      await _store(res.data['accessToken'], res.data['refreshToken']);
      return const GoogleAuthResult(loggedIn: true);
    } on DioException catch (e) {
      if (_errorCode(e) == 'GOOGLE_REGISTRATION_REQUIRED') {
        final data = e.response?.data as Map? ?? const {};
        return GoogleAuthResult(
          needsRegistration: true,
          idToken: idToken,
          email: (data['email'] ?? account.email).toString(),
          name: (data['name'] ?? account.displayName ?? '').toString(),
        );
      }
      debugPrint(
        '❌ [GOOGLE] login ${e.response?.statusCode}: ${e.response?.data}',
      );
      throw Exception(_serverError(e));
    }
  }

  /// Phase 2: same mobile endpoint, now with role + phone and NO `mode`.
  static Future<void> completeGoogleRegistration({
    required String idToken,
    required String role, // 'user' | 'agency'
    required String phone,
  }) async {
    try {
      final res = await ApiClient.post(
        Endpoints.googleAuth,
        data: {'idToken': idToken, 'role': role, 'phone': phone.trim()},
      );
      await _store(res.data['accessToken'], res.data['refreshToken']);
    } on DioException catch (e) {
      debugPrint(
        '❌ [GOOGLE] register ${e.response?.statusCode}: ${e.response?.data}',
      );
      throw Exception(_serverError(e));
    }
  }

  static Future<void> _store(dynamic access, dynamic refresh) async {
    if (access != null) {
      await SecureStorageService.write(key: 'access_token', value: access);
    }
    if (refresh != null) {
      await SecureStorageService.write(key: 'refresh_token', value: refresh);
    }
  }

  /// Clears the Google session so the picker reappears on next login.
  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('⚠️ [GOOGLE] signOut failed: $e');
    }
  }
}
