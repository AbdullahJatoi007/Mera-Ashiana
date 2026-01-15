import 'package:shared_preferences/shared_preferences.dart';

class LogoutService {
  /// Clears user session and local data
  static Future<void> logout() async {
    try {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Clear all stored data (Token, User Info, etc.)
      await prefs.clear();

      // If you use specific keys, you can use:
      // await prefs.remove('auth_token');

      print("User session cleared successfully.");
    } catch (e) {
      print("Error during logout service: $e");
    }
  }
}
