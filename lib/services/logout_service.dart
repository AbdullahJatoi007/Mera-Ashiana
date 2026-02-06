import 'package:mera_ashiana/services/auth/login_service.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LogoutService {
  static Future<void> logout() async {
    try {
      // 1. Wipe Cookie via LoginService
      await LoginService.logout();

      // 2. Wipe RAM Cache
      ProfileService.clearCache();

      // 3. Clear SharedPreferences (Local settings)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      debugPrint("Logged out: All storage and cache cleared.");
    } catch (e) {
      debugPrint("Logout error: $e");
      rethrow;
    }
  }
}
