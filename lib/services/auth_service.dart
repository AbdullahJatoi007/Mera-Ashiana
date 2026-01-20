import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://api.staging.mera-ashiana.com/api";
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Register a new user or agent
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String repassword,
    required String type, // Will be "user" or "agent" from UI
  }) async {
    final url = Uri.parse('$baseUrl/register');

    // Sync with Backend: If type is 'user', map to 'single_user' for MySQL enum
    final String backendType = type == "user" ? "single_user" : "agent";

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'repassword': repassword,
        'type': backendType, // Use corrected type
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Store JWT cookie securely
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        await _storage.write(
          key: 'auth_cookie',
          value: rawCookie.split(';').first,
        );
      }
      return data;
    }

    // Throw backend error
    throw data['message'] ?? data['error'] ?? 'Registration failed';
  }
}
