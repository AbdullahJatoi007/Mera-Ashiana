import 'dart:convert'; // Required for jsonEncode
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
      return {"success": true, "id": response.data['data']?['id']};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data?['error'] ?? "Request failed",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // 👇 NEW: UPDATE LISTING
  static Future<Map<String, dynamic>> updateListing({
    required int id,
    required Map<String, dynamic> data,
    List<File> newImageFiles = const [],
    List<int> keepExistingImageIds = const [],
  }) async {
    try {
      final List<MultipartFile> images = [];
      for (var file in newImageFiles) {
        images.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      final formData = FormData.fromMap({
        ...data,
        if (images.isNotEmpty) 'images': images,
        if (keepExistingImageIds.isNotEmpty)
          'keep_existing_image_ids': jsonEncode(keepExistingImageIds),
      });

      final response = await ApiClient.patch(
        Endpoints.listing(id),
        data: formData,
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? e.message ?? 'Update failed',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 👇 NEW: MARK AS SOLD
  static Future<Map<String, dynamic>> markAsSold({
    required int id,
    required String soldStatus, // 'sold' or 'available'
  }) async {
    try {
      final response = await ApiClient.patch(
        '${Endpoints.listing(id)}/sold-status',
        data: {'sold_status': soldStatus},
      );
      return {'success': true, 'sold_status': response.data['sold_status']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to update sold status',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
    try {
      final response = await ApiClient.delete(Endpoints.listing(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
