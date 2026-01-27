import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/services/auth/login_service.dart';
import 'package:mera_ashiana/models/user_model.dart';

class ProfileService {
  static const String baseUrl = "https://api-staging.mera-ashiana.com/api";

  // --- CACHE VARIABLE ---
  static User? _cachedUser;

  /// Clears the stored user data.
  /// Call this during Logout to ensure the next user doesn't see old data.
  static void clearCache() {
    _cachedUser = null;
  }

  /// Fetches profile data.
  /// [forceRefresh] will skip the cache and hit the API directly.
  static Future<User> fetchProfile({bool forceRefresh = false}) async {
    // 1. Check for Auth Cookie FIRST
    final cookie = await LoginService.getAuthCookie();

    // If no cookie exists, the user is logged out.
    // Clear RAM cache and throw an error immediately.
    if (cookie == null || cookie.isEmpty) {
      clearCache();
      throw '401'; // This triggers your ProfileScreen Guest View logic
    }

    // 2. Return cached data if available and refresh is not forced
    if (_cachedUser != null && !forceRefresh) {
      return _cachedUser!;
    }

    // 3. Proceed with API call
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Accept': 'application/json', 'Cookie': cookie},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update the cache with fresh data
        _cachedUser = User.fromJson(data['user']);
        return _cachedUser!;
      } else if (response.statusCode == 401) {
        clearCache();
        await LoginService.handleUnauthorized();
        throw '401';
      } else {
        throw data['message'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? imageFile,
  }) async {
    final cookie = await LoginService.getAuthCookie();

    if (cookie == null || cookie.isEmpty) {
      clearCache();
      throw 'Session expired';
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile/update'),
    );

    request.headers.addAll({'Accept': 'application/json', 'Cookie': cookie});

    request.fields['username'] = name;
    request.fields['email'] = email;
    request.fields['phone'] = phone;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      await fetchProfile(forceRefresh: true);
      return true;
    } else if (response.statusCode == 401) {
      clearCache();
      await LoginService.handleUnauthorized();
      throw 'Session expired';
    } else {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Update failed';
    }
  }
}
