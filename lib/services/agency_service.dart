import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/services/auth/login_service.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:mera_ashiana/models/user_model.dart';
import 'package:mera_ashiana/models/agency_model.dart';

class AgencyService {
  static const String baseUrl =
      "https://api-staging.mera-ashiana.com/api/agency";

  /// Fetches the current user's agency details
  /// Updated to handle both single object and list responses
  static Future<Agency?> fetchMyAgency() async {
    try {
      final cookie = await LoginService.getAuthCookie();
      if (cookie == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/my-agency'),
        headers: {'Accept': 'application/json', 'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        // 1. Check if the API returns a single agency object
        if (decoded['agency'] != null) {
          return Agency.fromJson(decoded['agency']);
        }
        // 2. Check if the API returns an array (common if query returns rows)
        else if (decoded['agencies'] != null &&
            (decoded['agencies'] as List).isNotEmpty) {
          return Agency.fromJson(decoded['agencies'][0]);
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Fetch Agency Error: $e");
      return null;
    }
  }

  /// Registers a new agency
  static Future<Map<String, dynamic>> registerAgency({
    required String agencyName,
    required String email,
    required String description,
    required String phone,
    required String address,
    File? logoFile,
  }) async {
    try {
      final cookie = await LoginService.getAuthCookie();
      if (cookie == null) throw "Authentication session expired.";

      // Get the current profile to link the user ID
      final User user = await ProfileService.fetchProfile();

      final Uri uri = Uri.parse('$baseUrl/register');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Accept': 'application/json', 'Cookie': cookie});

      // Prepare fields
      request.fields['agency_name'] = agencyName.trim();
      request.fields['email'] = email.trim().toLowerCase();
      request.fields['description'] = description.trim().isEmpty
          ? "No description"
          : description.trim();
      request.fields['phone'] = phone.trim();
      request.fields['address'] = address.trim().isEmpty
          ? "Not provided"
          : address.trim();
      request.fields['user_id'] = user.id.toString();

      // Attach file if it exists
      if (logoFile != null && await logoFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', logoFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": decoded['message'] ?? "Registered successfully",
          "agency": decoded['agency'] != null
              ? Agency.fromJson(decoded['agency'])
              : null,
        };
      } else {
        return {
          "success": false,
          "message": decoded['message'] ?? "Registration failed",
        };
      }
    } catch (e) {
      debugPrint("❌ Register Agency Error: $e");
      return {"success": false, "message": "Service error: $e"};
    }
  }
}
