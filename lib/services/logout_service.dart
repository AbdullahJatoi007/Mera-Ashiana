import 'package:shared_preferences/shared_preferences.dart';
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/profile_service.dart';

class LogoutService {
  static Future<void> logout() async {
    try {
      // 1. Wipe the Secure Storage (The Auth Cookie)
      await LoginService.logout();

      // 2. Wipe the Profile RAM Cache (The static User variable)
      ProfileService.clearCache();

      // 3. Clear SharedPreferences (Language/Theme/Settings)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print("All storage layers and memory caches cleared.");
    } catch (e) {
      print("Error during logout service: $e");
    }
  }
}
