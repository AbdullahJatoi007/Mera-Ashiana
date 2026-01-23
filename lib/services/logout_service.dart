import 'package:shared_preferences/shared_preferences.dart';
import 'package:mera_ashiana/services/auth/login_service.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:flutter/material.dart';

class LogoutService {
  /// Wipes all user-related data from storage and memory
  static Future<void> logout() async {
    try {
      // 1. Wipe Secure Storage (Cookie)
      await LoginService.logout();

      // 2. Wipe Profile RAM Cache
      ProfileService.clearCache();

      // 3. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      debugPrint("All storage layers and memory caches cleared.");
    } catch (e) {
      debugPrint("Error during logout service: $e");
      rethrow;
    }
  }
}
