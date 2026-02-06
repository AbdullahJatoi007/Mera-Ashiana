import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/network/endpoints.dart';
import 'package:mera_ashiana/services/auth/login_service.dart';

class ListingService {
  /// Real-time listings count
  static ValueNotifier<int> myListingsCount = ValueNotifier<int>(0);

  /// Sends both property details and images in a single Multipart request.
  static Future<Map<String, dynamic>> createListing({
    required Map<String, dynamic> data,
    required List<File> imageFiles,
  }) async {
    try {
      final cookie = await LoginService.getAuthCookie();
      var uri = Uri.parse(Endpoints.createListing);

      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Cookie': cookie ?? '',
        'Accept': 'application/json',
      });

      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final result = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Increment listing count in real-time
        myListingsCount.value += 1;

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
        Uri.parse(Endpoints.myListings),
        headers: {'Cookie': cookie ?? '', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        // Update real-time count
        myListingsCount.value = data.length;
        return data.map((json) => Listing.fromJson(json)).toList();
      }
      myListingsCount.value = 0;
      return [];
    } catch (e) {
      debugPrint("Fetch Error: $e");
      myListingsCount.value = 0;
      return [];
    }
  }

  /// Delete listing
  static Future<bool> deleteListing(int id) async {
    try {
      final cookie = await LoginService.getAuthCookie();
      final url = Uri.parse(Endpoints.deleteListing(id));

      final response = await http.delete(
        url,
        headers: {
          'Cookie': cookie ?? '',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Decrement count in real-time
        myListingsCount.value -= 1;
        return true;
      } else {
        debugPrint("Server rejected delete: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Delete Network Error: $e");
      return false;
    }
  }
}
