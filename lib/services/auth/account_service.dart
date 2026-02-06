import 'package:http/http.dart' as http;
import 'auth_config.dart';
import 'auth_service.dart';
import 'auth_exceptions.dart';
import 'package:mera_ashiana/core/api_client.dart';

class AccountService {
  // /// Sends DELETE request and clears local session
  // static Future<void> deleteUserAccount() async {
  //   try {
  //     final response = await http
  //         .delete(
  //           Uri.parse('${AuthConfig.baseUrl}/delete-account'),
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Accept': 'application/json',
  //             'Cookie': await AuthService.getAuthCookie() ?? '',
  //           },
  //         )
  //         .timeout(AuthConfig.connectionTimeout);
  //
  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       await AuthService.logout();
  //     } else {
  //       throw AuthException(
  //         'Failed to delete account. Status: ${response.statusCode}',
  //       );
  //     }
  //   } catch (e) {
  //     throw NetworkException('Could not connect to server to delete account.');
  //   }
  // }
}
