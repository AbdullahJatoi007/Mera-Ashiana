import 'package:flutter/material.dart';
import 'package:mera_ashiana/services/auth/secure_storage_service.dart';

class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  static Future<void> checkLoginStatus() async {
    final token = await SecureStorageService.read(key: 'access_token');
    isLoggedIn.value = (token != null && token.isNotEmpty);
  }

  static Future<void> initialize() => checkLoginStatus();
}
