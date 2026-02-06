import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';

class FavoriteService {
  static ValueNotifier<Set<int>> favoriteIds = ValueNotifier<Set<int>>({});
  static Map<int, PropertyModel> favoritesMap = {};
  static ValueNotifier<int> favoriteIdsCount = ValueNotifier<int>(0);

  static Future<bool> toggleFavorite(
    int propertyId,
    bool currentlyLiked, {
    PropertyModel? propertyData,
  }) async {
    // API routes are handled by our dynamic endpoint functions
    final String path = currentlyLiked
        ? Endpoints.unlikeProperty(propertyId)
        : Endpoints.likeProperty(propertyId);

    try {
      // Use DELETE for unlike and POST for like as per your logic
      final response = currentlyLiked
          ? await ApiClient.delete(path)
          : await ApiClient.post(path);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedSet = Set<int>.from(favoriteIds.value);

        if (currentlyLiked) {
          updatedSet.remove(propertyId);
          favoritesMap.remove(propertyId);
        } else {
          updatedSet.add(propertyId);
          if (propertyData != null) favoritesMap[propertyId] = propertyData;
        }

        favoriteIds.value = updatedSet;
        _updateCount();
        return true;
      }
      return false;
    } catch (e) {
      // Errors (401, timeout, etc.) are handled by ApiClient interceptor
      rethrow;
    }
  }

  static Future<void> fetchMyFavorites() async {
    try {
      final response = await ApiClient.get(Endpoints.myFavorites);

      // Dio automatically decodes JSON
      final List favList = response.data['data'] ?? [];

      final Set<int> ids = {};
      final Map<int, PropertyModel> newMap = {};

      for (var json in favList) {
        final prop = PropertyModel.fromJson(json);
        ids.add(prop.id);
        newMap[prop.id] = prop;
      }

      favoritesMap = newMap;
      favoriteIds.value = ids;
      _updateCount();
    } catch (e) {
      debugPrint("Fetch Favorites Error: $e");
    }
  }

  static void _updateCount() {
    favoriteIdsCount.value = favoriteIds.value.length;
  }
}
