import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mera_ashiana/network/endpoints.dart';

class GoogleLoginService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Use .instance for 7.2.0
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Sign in with Google and send token + captcha to backend
  static Future<void> signInWithGoogle({String captchaToken = ''}) async {
    try {
      // Open Google account picker
      final GoogleSignInAccount? account = await _googleSignIn.authenticate();
      if (account == null) throw 'Google sign-in cancelled';

      // Get tokens
      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw 'Failed to get Google ID token';

      // Send to backend
      final response = await http.post(
        Uri.parse(Endpoints.googleLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'captchaToken': captchaToken, // backend requires this
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Save cookie if backend sets it
        final rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          await _storage.write(
            key: 'auth_cookie',
            value: rawCookie.split(';').first,
          );
        }
      } else {
        throw data['message'] ?? 'Google login failed';
      }
    } catch (e) {
      rethrow;
    }
  }
}
