import 'package:mera_ashiana/core/network/api_client.dart';

import '../../../core/network/endpoints.dart';
import '../../../data./services/auth/auth_service.dart';

class AccountService {
  /// Sends DELETE request via ApiClient and clears local session
  static Future<void> deleteUserAccount() async {
    try {
      // 1. Determine the path.
      // Based on your Endpoints class, this should likely be a new entry
      // or mapped to the updateProfile base if your backend uses it for deletion.
      // For now, I'll use a likely path based on your 'updateProfile' pattern.
      const String deletePath = "${Endpoints.apiBase}/auth/profile/delete";

      final response = await ApiClient.delete(deletePath);

      // 2. If successful (200 OK or 204 No Content)
      if (response.statusCode == 200 || response.statusCode == 204) {
        // 3. Clear local tokens and logout the user
        await AuthService.logout();
      } else {
        throw Exception(
          'Failed to delete account. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // ApiClient interceptors will handle 401/Unauthorized,
      // so we just rethrow the connection/server error here.
      throw Exception('Could not connect to server to delete account: $e');
    }
  }
}
