import 'auth_service.dart';
import 'secure_storage_service.dart';

class LoginService {
  // Updated to read access_token
  static Future<String?> getAuthToken() =>
      SecureStorageService.read(key: 'access_token');

  static Future<void> logout() => AuthService.logout();

  // In your Dio Interceptor, this clears the token and updates AuthState
  static Future<void> handleUnauthorized() => AuthService.logout();

  static Future<void> login({
    required String email,
    required String password,
  }) => AuthService.login(email: email, password: password);
}