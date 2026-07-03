import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mera_ashiana/core/network/api_client.dart';
import '../../core/config/secrets.dart';
import '../../core/network/endpoints.dart';
import 'auth/secure_storage_service.dart';

/// Result of phase 1 (identity + mobile login attempt).
class GoogleAuthResult {
  final bool loggedIn; // existing user — tokens already stored
  final bool needsRegistration; // new user — collect role + phone next
  final String? googleAccessToken;
  final String? email;
  final String? name;

  const GoogleAuthResult({
    this.loggedIn = false,
    this.needsRegistration = false,
    this.googleAccessToken,
    this.email,
    this.name,
  });
}

class GoogleLoginService {
  static bool _initialized = false;

  static const String _webClientId =
      '1036155739982-12eubri97salh87u90mvju47au7rl0u8.apps.googleusercontent.com';
  static const String? _iosClientId = null;

  // ⚠️ ROTATED web client secret. Ships in the APK — stopgap only.
  static const String _webClientSecret = Secrets.googleWebClientSecret;

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

  static Future<void> _ensureInit() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: _webClientId,
      clientId: _iosClientId,
    );
    _initialized = true;
  }

  /// Phase 1: pick account → exchange code → try mobile LOGIN.
  /// Phase 1: pick account → exchange code → try mobile auth.
  ///
  /// [mode]
  ///   - null       : one-button flow (login, then register on 404)
  ///   - 'login'    : login only
  ///   - 'register' : explicit register intent
  static Future<GoogleAuthResult> startGoogleSignIn({String? mode}) async {
    await _ensureInit();

    // 1) identity
    final GoogleSignInAccount account = await GoogleSignIn.instance
        .authenticate();

    // 2) server auth code (issued FOR the web client)
    final serverAuth = await account.authorizationClient.authorizeServer(const [
      'email',
      'profile',
    ]);

    if (serverAuth == null) {
      throw Exception('Google did not return a server auth code.');
    }

    // 3) exchange ON DEVICE → web-client access token
    final String accessToken;
    try {
      final tokenRes = await Dio().post(
        'https://oauth2.googleapis.com/token',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'code': serverAuth.serverAuthCode,
          'client_id': _webClientId,
          'client_secret': _webClientSecret,
          'grant_type': 'authorization_code',
          'redirect_uri': '',
        },
      );

      accessToken = tokenRes.data['access_token'] as String;
    } on DioException catch (e) {
      debugPrint('❌ [GOOGLE] code exchange failed: ${e.response?.data}');
      throw Exception(_serverError(e));
    }

    if (kDebugMode) {
      await _debugInspectToken(accessToken);
    }

    // Default to login if no mode supplied.
    final requestMode = mode ?? 'login';

    try {
      final res = await ApiClient.post(
        Endpoints.googleAuth,
        data: {'access_token': accessToken, 'mode': requestMode},
      );

      await _store(
        res.data['accessToken'] ?? res.data['token'],
        res.data['refreshToken'],
      );

      return const GoogleAuthResult(loggedIn: true);
    } on DioException catch (e) {
      // One-button flow OR explicit login:
      // if account doesn't exist, ask caller to complete registration.
      if ((mode == null || mode == 'login') && e.response?.statusCode == 404) {
        return GoogleAuthResult(
          needsRegistration: true,
          googleAccessToken: accessToken,
          email: account.email,
          name: account.displayName,
        );
      }

      throw Exception(_serverError(e));
    }
  }

  /// Phase 2: passwordless create via the WEB endpoint (accepts phone).
  static Future<void> completeGoogleRegistration({
    required String googleAccessToken,
    required String role, // 'user' | 'agency'
    required String phone,
  }) async {
    final Response res;
    try {
      // raw Dio: no interceptors, and we read the Set-Cookie header ourselves.
      res = await Dio().post(
        Endpoints.webGoogleAuth,
        data: {
          'access_token': googleAccessToken,
          'role': role,
          'phone': phone.trim(),
          // no 'mode' → backend find-or-creates (creates this new user)
        },
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      debugPrint(
        '❌ [GOOGLE-WEB] ${e.response?.statusCode}: ${e.response?.data}',
      );
      throw Exception(_serverError(e));
    }

    final appAccess = res.data['accessToken'] ?? res.data['token'];
    final refresh = _refreshFromSetCookie(res.headers.map['set-cookie']);
    if (refresh == null) {
      debugPrint('⚠️ [GOOGLE-WEB] no refresh cookie — session may not refresh');
    }
    await _store(appAccess, refresh);
  }

  static Future<void> _store(dynamic access, dynamic refresh) async {
    if (access != null) {
      await SecureStorageService.write(key: 'access_token', value: access);
    }
    if (refresh != null) {
      await SecureStorageService.write(key: 'refresh_token', value: refresh);
    }
  }

  /// Pulls the cookie value out of the first Set-Cookie header (name-agnostic).
  static String? _refreshFromSetCookie(List<String>? cookies) {
    if (cookies == null || cookies.isEmpty) return null;
    final pair = cookies.first.split(';').first.trim(); // "<name>=<value>"
    final eq = pair.indexOf('=');
    if (eq < 0) return null;
    final value = pair.substring(eq + 1).trim();
    return value.isEmpty ? null : value;
  }

  static Future<void> _debugInspectToken(String accessToken) async {
    try {
      final r = await Dio().get(
        'https://www.googleapis.com/oauth2/v3/tokeninfo',
        queryParameters: {'access_token': accessToken},
      );
      debugPrint(
        '🔎 [tokeninfo] aud = ${r.data['aud']}',
      ); // expect ...12eubri...
    } catch (e) {
      debugPrint('🔎 [tokeninfo] inspection failed: $e');
    }
  }

  static Future<void> signOut() async => GoogleSignIn.instance.signOut();
}
