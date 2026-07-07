import 'dart:convert'; // Required for jsonEncode
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../models/listing_model.dart';

class ListingService {
  static ValueNotifier<int> myListingsCount = ValueNotifier<int>(0);

  /// Re-syncs [myListingsCount] with the server's true count, without
  /// needing the full listing objects. Cheap to call whenever the count
  /// might be stale — e.g. when ProfileScreen loads, or after any action
  /// that could have changed how many listings the user has.
  static Future<void> refreshMyListingsCount() async {
    try {
      final response = await ApiClient.get(Endpoints.myListings);
      final List data = response.data['data'] ?? [];
      myListingsCount.value = data.length;
    } catch (e) {
      // Leave the existing value as-is on failure — don't zero out a
      // count the user was already correctly seeing just because a
      // background refresh hiccuped.
      debugPrint("refreshMyListingsCount error: $e");
    }
  }

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

      // Optimistic bump so the UI feels instant. refreshMyListingsCount()
      // (called by the screen after this returns) will correct it to the
      // true server value shortly after.
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
      final ok = response.statusCode == 200 || response.statusCode == 204;
      if (ok && myListingsCount.value > 0) {
        // Keep the badge in sync on delete too — this was missing before,
        // so deleting a listing left the count one too high until the
        // user happened to revisit MyListingsScreen.
        myListingsCount.value -= 1;
      }
      return ok;
    } catch (e) {
      return false;
    }
  }
}
