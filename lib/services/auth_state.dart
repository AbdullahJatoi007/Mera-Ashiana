import 'package:flutter/material.dart';
import 'package:mera_ashiana/services/login_service.dart';

class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  static Future<void> checkLoginStatus() async {
    try {
      final String? cookie = await LoginService.getAuthCookie();
      // If cookie exists, we consider the user logged in
      isLoggedIn.value = (cookie != null && cookie.isNotEmpty);
    } catch (e) {
      isLoggedIn.value = false;
    }
  }

  static Future<void> initialize() => checkLoginStatus();
}
