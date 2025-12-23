import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://yourapi.com"; // Replace with your backend API

  // ---------------- REGISTER ----------------
  /// Registers a new user and returns response from backend
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

    // --- Logging request ---
    print('--- REGISTER REQUEST ---');
    print('POST $url');
    print('Headers: {"Content-Type": "application/json"}');
    print('Body: ${jsonEncode(bodyData)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyData),
    );

    // --- Logging response ---
    print('--- REGISTER RESPONSE ---');
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
    print('Headers: ${response.headers}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 405) {
      throw Exception(
          'Method Not Allowed (405). Check if your backend expects POST at this endpoint.');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
