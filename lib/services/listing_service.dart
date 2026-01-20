import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'login_service.dart';

class ListingService {
  static const String baseUrl = "http://api.staging.mera-ashiana.com/api/listings";

  static Future<Map<String, dynamic>> createListing({
    required Map<String, String> data,
    required List<File> imageFiles,
  }) async {
    try {
      final cookie = await LoginService.getAuthCookie();
      if (cookie == null) throw "Session expired. Please login again.";

      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add Headers
      request.headers.addAll({
        'Cookie': cookie,
        'Accept': 'application/json',
      });

      // Add Text Fields (Matches your Controller req.body)
      request.fields.addAll(data);

      // Add Multiple Images
      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Listing Create Status: ${response.statusCode}");

      final result = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {"success": true, "message": "Listing submitted for approval!"};
      } else {
        return {"success": false, "message": result['message'] ?? "Failed to create listing"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}