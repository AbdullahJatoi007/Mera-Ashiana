import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';

class ListingService {
  static ValueNotifier<int> myListingsCount = ValueNotifier<int>(0);

  static Future<Map<String, dynamic>> createListing({
    required Map<String, dynamic> data,
    required List<File> imageFiles,
  }) async {
    try {
      // Prepare multi-file FormData
      List<MultipartFile> images = [];
      for (var file in imageFiles) {
        images.add(await MultipartFile.fromFile(file.path));
      }

      FormData formData = FormData.fromMap({...data, 'images': images});

      final response = await ApiClient.post(
        Endpoints.createListing,
        data: formData,
      );

      myListingsCount.value += 1;
      return {"success": true, "id": response.data['id']};
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
      myListingsCount.value = 0;
      return [];
    }
  }

  static Future<bool> deleteListing(int id) async {
    final response = await ApiClient.delete(Endpoints.deleteListing(id));
    if (response.statusCode == 200 || response.statusCode == 204) {
      myListingsCount.value -= 1;
      return true;
    }
    return false;
  }
}
