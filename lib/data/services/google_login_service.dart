import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mera_ashiana/core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import 'auth/secure_storage_service.dart';

class GoogleLoginService {
  static bool _initialized = false;

  // ⚠️ MUST equal the backend's GOOGLE_CLIENT_ID — the WEB OAuth client ID.
  static const String _webClientId =
      '1036155739982-20djadcgpfr33srf98tm7943r863kum9.apps.googleusercontent.com';

  // iOS only (or set via Info.plist). Leave null on Android.
  static const String? _iosClientId = null;

  // Pulls the backend's real error message out of a DioException so the toast
  // shows e.g. "No account found for this Google address." instead of Dio's
  // generic multi-line paragraph.
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
    debugPrint('🟢 [GOOGLE] initialize() serverClientId=$_webClientId');
    await GoogleSignIn.instance.initialize(
      serverClientId: _webClientId,
      clientId: _iosClientId,
    );
    _initialized = true;
    debugPrint('🟢 [GOOGLE] initialize() done');
  }

  /// [mode] is optional:
  ///   - null / 'register' → backend finds-or-creates the account (default).
  ///   - 'login'           → backend refuses to auto-create and returns 404
  ///                         "No account found..." if the user doesn't exist.
  static Future<bool> signInWithGoogle({
    String role = 'user',
    String? mode,
  }) async {
    await _ensureInit();

    // 1) Account picker (identity)
    final GoogleSignInAccount account;
    try {
      debugPrint('🟢 [GOOGLE] authenticate() — opening picker...');
      account = await GoogleSignIn.instance.authenticate();
      debugPrint(
        '🟢 [GOOGLE] authenticate OK — ${account.email} (${account.id})',
      );
    } on GoogleSignInException catch (e, st) {
      // Config errors (missing SHA-1 / wrong serverClientId) ALSO land here
      // as code=canceled with a "[16] ..." description. Do NOT swallow them.
      debugPrint('❌ [GOOGLE] authenticate FAILED');
      debugPrint('❌ [GOOGLE] code=${e.code}');
      debugPrint('❌ [GOOGLE] description=${e.description}');
      debugPrint('❌ [GOOGLE] details=${e.details}');
      debugPrint('❌ [GOOGLE] $st');
      rethrow;
    } catch (e, st) {
      debugPrint('❌ [GOOGLE] authenticate unexpected: $e\n$st');
      rethrow;
    }

    // 2) Authorization → real OAuth access token (what the backend introspects)
    final String accessToken;
    try {
      debugPrint('🟢 [GOOGLE] authorizeScopes(email, profile)...');
      final authz = await account.authorizationClient.authorizeScopes(const [
        'email',
        'profile',
      ]);
      accessToken = authz.accessToken;
      debugPrint('🟢 [GOOGLE] access token length=${accessToken.length}');
    } on GoogleSignInException catch (e, st) {
      debugPrint(
        '❌ [GOOGLE] authorizeScopes FAILED '
        'code=${e.code} desc=${e.description}\n$st',
      );
      rethrow;
    }

    if (accessToken.isEmpty) {
      throw Exception('Google authorization returned an empty access token.');
    }

    // 2b) DEBUG ONLY — inspect the token exactly as the backend will.
    // `aud` MUST equal backend GOOGLE_CLIENT_ID or you'll get a 401 mismatch.
    // Gated so it never runs (and never adds latency) in release builds.
    if (kDebugMode) {
      await _debugInspectToken(accessToken);
    }

    // 3) Hand the access token to the backend
    debugPrint(
      '🟢 [GOOGLE] POST ${Endpoints.googleAuth} (mode=${mode ?? '-'})',
    );
    final Response res;
    try {
      res = await ApiClient.post(
        Endpoints.googleAuth,
        data: {
          'access_token': accessToken,
          'role': role,
          if (mode != null) 'mode': mode,
        },
      );
    } on DioException catch (e) {
      debugPrint(
        '❌ [GOOGLE] backend ${e.response?.statusCode}: ${e.response?.data}',
      );
      // Surfaces the backend's real message (e.g. 404 "No account found...",
      // 401 "audience mismatch") instead of the generic Dio paragraph.
      throw Exception(_serverError(e));
    }
    debugPrint('🟢 [GOOGLE] backend ${res.statusCode} ${res.data}');

    // 4) Store the app's own session tokens
    final appAccess = res.data['accessToken'] ?? res.data['token'];
    if (appAccess != null) {
      await SecureStorageService.write(key: 'access_token', value: appAccess);
    }
    final appRefresh = res.data['refreshToken'];
    if (appRefresh != null) {
      await SecureStorageService.write(key: 'refresh_token', value: appRefresh);
    }
    debugPrint('🟢 [GOOGLE] stored tokens. created=${res.data['created']}');
    return true;
  }

  /// Calls Google's tokeninfo endpoint with a raw Dio (no interceptors) and
  /// logs what the backend's `aud` check will see. Debug builds only.
  static Future<void> _debugInspectToken(String accessToken) async {
    try {
      final r = await Dio().get(
        'https://www.googleapis.com/oauth2/v3/tokeninfo',
        queryParameters: {'access_token': accessToken},
      );
      debugPrint('🔎 [tokeninfo] aud   = ${r.data['aud']}');
      debugPrint('🔎 [tokeninfo] azp   = ${r.data['azp']}');
      debugPrint(
        '🔎 [tokeninfo] email = ${r.data['email']} '
        'verified=${r.data['email_verified']}',
      );
      debugPrint('🔎 [tokeninfo] scope = ${r.data['scope']}');
      debugPrint('🔎 [tokeninfo] >>> aud MUST equal backend GOOGLE_CLIENT_ID');
    } catch (e) {
      debugPrint('🔎 [tokeninfo] inspection failed: $e');
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
  }
}
