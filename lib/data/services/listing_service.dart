import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../models/listing_model.dart';

class ListingService {
  static ValueNotifier<int> myListingsCount = ValueNotifier<int>(0);

  static Future<Map<String, dynamic>> createListing({
    required Map<String, dynamic> data,
    required List<File> imageFiles,
  }) async {
    try {
      final List<MultipartFile> images = [];

      for (var file in imageFiles) {
        images.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      final formData = FormData.fromMap({...data, 'images': images});

      final response = await ApiClient.post(Endpoints.listings, data: formData);

      myListingsCount.value += 1;

      return {"success": true, "id": response.data['data']['id']};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<List<Listing>> getMyListings() async {
    try {
      final response = await ApiClient.get(Endpoints.myListings);

      final List data = response.data['data'] ?? [];

      myListingsCount.value = data.length;

      return data.map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      debugPrint("ListingService Error: $e");

      myListingsCount.value = 0;

      return [];
    }
  }

  static Future<bool> deleteListing(int id) async {
    try {
      final response = await ApiClient.delete(Endpoints.listing(id));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Delete Listing Error: $e");
      return false;
    }
  }
}
