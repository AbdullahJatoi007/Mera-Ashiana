import 'package:http/http.dart';
import 'package:mera_ashiana/core/api_client.dart';
import 'package:mera_ashiana/network/endpoints.dart';
import 'package:mera_ashiana/services/auth/auth_service.dart';
import 'package:mera_ashiana/services/logout_service.dart';

import 'package:mera_ashiana/services/auth/secure_storage_service.dart';
import 'auth_exceptions.dart';

class AccountDeletionService {
  /// Google Play Policy compliant deletion:
  /// Triggers backend data erasure and wipes local session.
  static Future<void> requestAccountDeletion() async {
    // 1. Get the Bearer Token instead of the Cookie
    final token = await SecureStorageService.read(key: 'access_token');

    if (token == null) {
      throw UnauthorizedException('No active session found.');
    }

    try {
      // 2. Use your ApiClient.delete method.
      // The Interceptor will automatically add the "Authorization: Bearer" header.
      final response = await ApiClient.delete('/account/delete');

      // 3. Handle successful deletion (200, 202, or 204)
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        // Clear local storage and tokens immediately
        await AuthService.logout();
      } else {
        throw AuthException('Deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException('Unable to process deletion. Check your connection.');
    }
  }
}