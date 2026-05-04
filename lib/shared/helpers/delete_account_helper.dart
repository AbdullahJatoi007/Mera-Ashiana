import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/network/endpoints.dart';
import '../../data/services/auth/account_service.dart';
import '../widgets/base/main_scaffold.dart';
import '../../data/services/auth/auth_config.dart';
import '../../data/services/auth/auth_exceptions.dart';
import '../../data/services/auth/auth_service.dart';
import '../../data/services/auth/secure_storage_service.dart';

class AccountDeletionService {
  static Future<void> requestAccountDeletion() async {
    // ✅ Changed from getAuthCookie to reading access_token
    final token = await SecureStorageService.read(key: 'access_token');

    if (token == null) {
      throw UnauthorizedException('No active session found.');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('${Endpoints.apiBase}/account/delete'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token', // ✅ Use Bearer Token
            },
          )
          .timeout(AuthConfig.connectionTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await AuthService.logout();
      } else {
        throw AuthException('Deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkException('Unable to process deletion.');
    }
  }
}
