import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:mera_ashiana/models/user_model.dart';

class AgencyService {
  // Base URL for the agency API
  static const String baseUrl =
      "http://api.staging.mera-ashiana.com/api/agency";

  /// Registers a new agency with high safety measures for fields and unique slugs.
  static Future<Map<String, dynamic>> registerAgency({
    required String agencyName,
    required String email,
    required String description,
    required String phone,
    required String address,
    File? logoFile,
  }) async {
    try {
      // 1. Authentication Check
      final cookie = await LoginService.getAuthCookie();
      if (cookie == null) {
        throw "Authentication session expired. Please login again.";
      }

      // 2. Fetch User Profile to verify role
      final User user = await ProfileService.fetchProfile();
      if (user.type != 'agent') {
        return {
          "success": false,
          "message": "Only verified agents can create agencies.",
        };
      }

      // 3. Prepare Multipart Request
      final Uri uri = Uri.parse('$baseUrl/register');
      var request = http.MultipartRequest('POST', uri);

      // 4. Headers
      request.headers.addAll({'Accept': 'application/json', 'Cookie': cookie});

      // 5. SLUG GENERATION (Safety Feature)
      // Adding a timestamp ensures that even if you use the same name twice,
      // the database won't crash due to a "Duplicate Slug" error.
      String uniqueSlug =
          "${agencyName.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${DateTime.now().millisecondsSinceEpoch}";

      // 6. FIELD MAPPING (Sanitized)
      request.fields['agency_name'] = agencyName.trim();
      request.fields['slug'] = uniqueSlug;
      request.fields['email'] = email.trim().toLowerCase();
      request.fields['description'] = description.isEmpty
          ? "No description provided"
          : description.trim();
      request.fields['phone'] = phone.trim();
      request.fields['address'] = address.isEmpty
          ? "Not provided"
          : address.trim();
      request.fields['user_id'] = user.id.toString();

      // 7. LOGO HANDLING
      // Key "logo" must match the backend's uploadLogo.single("logo")
      if (logoFile != null && await logoFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', logoFile.path),
        );
      }

      // 8. Send Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // --- DEBUGGING LOGS ---
      debugPrint("--- AGENCY REGISTRATION DEBUG ---");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Full Response Body: ${response.body}");

      // 9. Handle Responses
      if (response.body.contains('<!DOCTYPE html>')) {
        return {
          "success": false,
          "message":
              "Server Error: Endpoint not found or server crashed (404/500).",
        };
      }

      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": decoded['message'] ?? "Agency registered successfully!",
          "data": decoded['agency'],
        };
      } else {
        // Detailed error for 500 status codes
        String errorMsg = decoded['message'] ?? "Registration failed.";
        if (response.statusCode == 500) {
          errorMsg =
              "Server Error (500): Try submitting without a logo to check if it's a folder issue.";
        }
        return {"success": false, "message": errorMsg};
      }
    } catch (e) {
      debugPrint("❌ AgencyService Error: $e");
      return {"success": false, "message": "Service encountered an error: $e"};
    }
  }
}
