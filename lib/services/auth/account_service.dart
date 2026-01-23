import 'package:http/http.dart' as http;
import 'auth_config.dart';
import 'auth_service.dart';
import 'auth_exceptions.dart';

class AccountService {
  /// Sends a DELETE request to the backend and clears local session
  static Future<void> deleteUserAccount() async {
    try {
      // Note: We use AuthService's internal header logic to get the cookie
      final response = await http.delete(
        Uri.parse('${AuthConfig.baseUrl}/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Manually getting cookie if your AuthService helper is private
          'Cookie': await AuthService.getAuthCookie() ?? '',
        },
      ).timeout(AuthConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Essential: Wipe all local data once account is gone
        await AuthService.logout();
      } else {
        throw AuthException('Failed to delete account. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw NetworkException('Could not connect to server to delete account.');
    }
  }
}