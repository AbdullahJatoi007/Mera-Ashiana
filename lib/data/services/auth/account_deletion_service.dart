import 'package:mera_ashiana/core/network/api_client.dart';
import 'package:mera_ashiana/data/services/auth/secure_storage_service.dart';
import 'package:mera_ashiana/data/services/logout_service.dart'; // IMPORT THE FIXED SERVICE
import 'auth_exceptions.dart';

class AccountDeletionService {
  /// Google Play Policy compliant deletion:
  /// Triggers backend data erasure and wipes local session.
  static Future<void> requestAccountDeletion() async {
    // 1. Get the Bearer Token to verify the session exists locally
    final token = await SecureStorageService.read(key: 'access_token');

    if (token == null) {
      throw UnauthorizedException('No active session found.');
    }

    try {
      // 2. Call your Express backend.
      // The Interceptor should automatically attach the Bearer token.
      final response = await ApiClient.delete('/account/delete');

      // 3. Handle successful deletion (Your Express backend sends 204)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // FIX: Call the newly updated LogoutService!
        // This clears SecureStorage, SharedPreferences, Cache, AND updates the UI state.
        await LogoutService.logout();
      } else {
        throw AuthException('Deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      // Pass authentication exceptions through, wrap everything else in a network error
      if (e is AuthException || e is UnauthorizedException) rethrow;
      throw NetworkException(
        'Unable to process deletion. Check your connection.',
      );
    }
  }
}
