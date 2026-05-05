import 'package:mera_ashiana/core/network/api_client.dart';
import 'package:mera_ashiana/core/network/endpoints.dart';
import 'package:mera_ashiana/data/services/logout_service.dart';
import 'auth_exceptions.dart';

class AccountDeletionService {
  /// Deletes account from backend and logs user out locally
  static Future<void> requestAccountDeletion() async {
    try {
      final response = await ApiClient.delete(Endpoints.deleteAccount);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        await LogoutService.logout();
      } else {
        throw AuthException('Deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is UnauthorizedException) rethrow;

      throw NetworkException(
        'Unable to process deletion. Check your connection.',
      );
    }
  }
}
