import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:mera_ashiana/models/user_model.dart'; // Ensure this is imported

class AgencyService {
  static const String baseUrl = "http://api.staging.mera-ashiana.com/api";

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
      if (cookie == null) throw "Auth cookie not found";

      // 1. Get User Profile and ensure ID is a String
      final User user = await ProfileService.fetchProfile();
      final String userIdString = user.id.toString();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register'),
      );

      request.headers.addAll({'Accept': 'application/json', 'Cookie': cookie});

      // 2. Map fields to match your Controller's req.body
      request.fields['agency_name'] = agencyName;
      request.fields['email'] = email;
      request.fields['description'] = description;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['user_id'] = userIdString; // Explicitly send converted ID

      // 3. Attach Logo
      if (logoFile != null && await logoFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', logoFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // LOG THIS IN YOUR CONSOLE
      debugPrint("--- API CALL DEBUG ---");
      debugPrint("Payload UserID: $userIdString");
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true, "message": decoded['message'] ?? "Success"};
      } else {
        return {
          "success": false,
          "message": decoded['message'] ?? "Server Error",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Service Error: $e"};
    }
  }
}
