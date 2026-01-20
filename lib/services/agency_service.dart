import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:mera_ashiana/models/user_model.dart';

class AgencyService {
  // CORRECTED: Changed from /api/agencies to /api/agency to match your backend app.js
  static const String baseUrl =
      "http://api.staging.mera-ashiana.com/api/agency";

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

      // 2. Fetch Profile & Verification
      final User user = await ProfileService.fetchProfile();

      // Ensure only agents can proceed
      if (user.type != 'agent') {
        return {
          "success": false,
          "message": "Only verified agents can create agencies.",
        };
      }

      // 3. Prepare Multipart Request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register'),
      );

      // Add Headers - Cookie is vital for authMiddleware
      request.headers.addAll({'Accept': 'application/json', 'Cookie': cookie});

      // 4. Map fields to match your Controller's req.body exactly
      request.fields['agency_name'] = agencyName;
      request.fields['email'] = email;
      request.fields['description'] = description;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['user_id'] = user.id.toString();

      // 5. Attach Logo if selected
      if (logoFile != null && await logoFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', logoFile.path),
        );
      }

      // 6. Send Request and Handle Response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("--- AGENCY API DEBUG ---");
      debugPrint("URL: $baseUrl/register");
      debugPrint("Status: ${response.statusCode}");

      // 7. Prevent "Unexpected character <" crash
      // If server returns HTML, it's a 404/500 route error
      if (response.body.contains('<!DOCTYPE html>')) {
        return {
          "success": false,
          "message":
              "Server Error: Route not found or Server crashed. Check URL and logs.",
        };
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": decoded['message'] ?? "Agency registered successfully!",
        };
      } else {
        return {
          "success": false,
          "message":
              decoded['message'] ?? "Registration failed. Please check inputs.",
        };
      }
    } catch (e) {
      debugPrint("AgencyService Error: $e");
      return {"success": false, "message": "Service Error: $e"};
    }
  }
}
