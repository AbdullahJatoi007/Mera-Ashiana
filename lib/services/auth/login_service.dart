import 'auth_config.dart';
import 'auth_service.dart';

class LoginService {
  static const String baseUrl = AuthConfig.baseUrl;

  static Future<String?> getAuthCookie() => AuthService.getAuthCookie();

  static Future<void> logout() => AuthService.logout();

  static Future<void> handleUnauthorized() => AuthService.handleUnauthorized();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => AuthService.login(email: email, password: password);
}
