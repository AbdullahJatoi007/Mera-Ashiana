import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Replace with your actual backend URL
  static const String baseUrl = "https://yourapi.com/api";

  // Google recommendation: Persistent secure storage for tokens/cookies
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Helper to get common headers with the saved session cookie
  static Future<Map<String, String>> getAuthHeaders() async {
    final String? cookie = await _storage.read(key: 'auth_cookie');
    return {
      'Content-Type': 'application/json',
      if (cookie != null) 'cookie': cookie,
    };
  }

  // ---------------- REGISTER ----------------
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String repassword,
    required String type,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final bodyData = {
      'username': username,
      'email': email,
      'password': password,
      'repassword': repassword,
      'type': type,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // --- COOKIE HANDLING (CRITICAL) ---
        // We capture the Set-Cookie header to maintain the session
        final String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          await _storage.write(key: 'auth_cookie', value: rawCookie);
        }

        return response.body.isEmpty
            ? {'message': 'Registered successfully!'}
            : jsonDecode(response.body);
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};
        throw errorBody['message'] ?? 'Registration failed';
      }
    } catch (e) {
      // Re-throw for the UI to catch
      throw e.toString();
    }
  }
}
