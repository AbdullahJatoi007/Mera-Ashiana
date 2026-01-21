import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/services/login_service.dart';

class ListingService {
  static const String _baseUrl = "http://api.staging.mera-ashiana.com/api";

  static Future<Map<String, dynamic>> createListing({
    required Map<String, dynamic> data,
  }) async {
    try {
      final cookie = await LoginService.getAuthCookie();
      final response = await http.post(
        Uri.parse("$_baseUrl/listings"),
        headers: {
          'Cookie': cookie ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true, "id": result['data']['id']};
      }
      return {"success": false, "message": result['message'] ?? "Server Error"};
    } catch (e) {
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

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
      debugPrint("Error: $e");
      return [];
    }
  }

  static Future<bool> uploadImages(int listingId, List<File> imageFiles) async {
    try {
      final cookie = await LoginService.getAuthCookie();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/listings/$listingId/images"),
      );
      request.headers.addAll({
        'Cookie': cookie ?? '',
        'Accept': 'application/json',
      });

      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      final res = await request.send();
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
