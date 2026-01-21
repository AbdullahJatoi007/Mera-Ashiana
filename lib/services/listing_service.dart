import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/services/login_service.dart';

class ListingService {
  static const String _baseUrl = "http://api.staging.mera-ashiana.com/api";

  /// Sends both property details and images in a single Multipart request.
  static Future<Map<String, dynamic>> createListing({
    required Map<String, dynamic> data,
    required List<File> imageFiles,
  }) async {
    try {
      final cookie = await LoginService.getAuthCookie();
      var uri = Uri.parse("$_baseUrl/listings");

      // MultipartRequest is required for 'multipart/form-data' (Files + Fields)
      var request = http.MultipartRequest('POST', uri);

      // 1. Add Headers
      request.headers.addAll({
        'Cookie': cookie ?? '',
        'Accept': 'application/json',
      });

      // 2. Add Text Fields
      // Multer expects all non-file fields as Strings
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // 3. Add Images
      // Changed from 'images[]' to 'images' to fix MulterError: Unexpected field
      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      // 4. Execute the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final result = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Safe navigation to handle different backend response structures
        var responseData = result['data'];
        var id = responseData != null ? responseData['id'] : result['id'];

        return {"success": true, "id": id};
      }

      return {
        "success": false,
        "message": result['message'] ?? "Server Error: ${response.statusCode}",
      };
    } catch (e) {
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  /// Fetches listings belonging to the logged-in user
  static Future<List<Listing>> getMyListings() async {
    try {
      final cookie = await LoginService.getAuthCookie();
      final response = await http.get(
        Uri.parse("$_baseUrl/my-listings"),
        headers: {'Cookie': cookie ?? '', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        return data.map((json) => Listing.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Fetch Error: $e");
      return [];
    }
  }
}
