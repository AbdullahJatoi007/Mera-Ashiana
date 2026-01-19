import 'package:flutter/material.dart';
import 'package:mera_ashiana/services/login_service.dart';

class AuthState {
  /// Global notifier that screens like Profile and Favourites listen to
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  /// Standard method for Splash Screen initialization
  static Future<void> checkLoginStatus() async {
    try {
      final String? cookie = await LoginService.getAuthCookie();
      // Update global notifier: true if cookie exists, false if null
      isLoggedIn.value = (cookie != null && cookie.isNotEmpty);
      debugPrint(
        "Auth Check: User is ${isLoggedIn.value ? 'Logged In' : 'Guest'}",
      );
    } catch (e) {
      isLoggedIn.value = false;
      debugPrint("Error checking auth status: $e");
    }
  }

  /// Alias for checkLoginStatus
  static Future<void> initialize() => checkLoginStatus();
}
