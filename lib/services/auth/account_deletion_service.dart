import 'package:http/http.dart' as http;
import 'auth_config.dart';
import 'auth_service.dart';
import 'auth_exceptions.dart';

class AccountDeletionService {
  /// Google Play Policy compliant deletion:
  /// Triggers backend data erasure and wipes local session.
  static Future<void> requestAccountDeletion() async {
    final cookie = await AuthService.getAuthCookie();

    if (cookie == null) {
      throw UnauthorizedException('No active session found.');
    }

    try {
      final response = await http.delete(
        Uri.parse('${AuthConfig.baseUrl}/account/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': cookie,
        },
      ).timeout(AuthConfig.connectionTimeout);

      // 200 (OK), 202 (Accepted), or 204 (No Content) are valid success codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Essential: Clear local storage and cookies immediately
        await AuthService.logout();
      } else {
        // Parse backend error if available
        throw AuthException('Deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException('Unable to process deletion. Check your connection.');
    }
  }
}