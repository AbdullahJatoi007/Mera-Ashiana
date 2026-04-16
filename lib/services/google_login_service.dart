  import 'package:google_sign_in/google_sign_in.dart';
  import 'package:mera_ashiana/core/api_client.dart';
  import 'package:mera_ashiana/services/auth/secure_storage_service.dart';
  import 'package:mera_ashiana/network/endpoints.dart';

  class GoogleLoginService {
    static final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    static Future<void> signInWithGoogle({String role = 'user'}) async {
      try {
        final account = await _googleSignIn.signIn();
        if (account == null) return;

        final auth = await account.authentication;

        // IMPORTANT FIX:
        final idToken = auth.idToken;

        if (idToken == null) {
          throw Exception("Google ID Token is null");
        }

        final res = await ApiClient.post(
          Endpoints.googleAuth,
          data: {
            'access_token': idToken, // backend should accept idToken
            'role': role,
          },
        );

        final token = res.data['accessToken'];

        if (token != null) {
          await SecureStorageService.write(
            key: 'access_token',
            value: token,
          );
        }
      } catch (e) {
        rethrow;
      }
    }

    static Future<void> signOut() async {
      await _googleSignIn.signOut();
    }
  }