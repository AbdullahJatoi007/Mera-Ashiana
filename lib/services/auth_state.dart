import 'package:flutter/material.dart';
import 'package:mera_ashiana/services/auth/login_service.dart';

class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  static Future<void> checkLoginStatus() async {
    final String? cookie = await LoginService.getAuthCookie();
    isLoggedIn.value = (cookie != null && cookie.isNotEmpty);
  }

  static Future<void> initialize() => checkLoginStatus();
}
