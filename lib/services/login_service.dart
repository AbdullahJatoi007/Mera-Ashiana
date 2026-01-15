import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginService {
  static const String baseUrl = "http://api.staging.mera-ashiana.com/api";
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> getAuthCookie() async =>
      await _storage.read(key: 'auth_cookie');

  static Future<void> logout() async =>
      await _storage.delete(key: 'auth_cookie');

  // New: Use this when the API returns 401
  static Future<void> handleUnauthorized() async {
    await logout();
    // You can add a global key navigation here to redirect to Login
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        await _storage.write(
          key: 'auth_cookie',
          value: rawCookie.split(';').first,
        );
      }
      return data;
    } else {
      throw data['message'] ?? 'Login failed';
    }
  }
}
