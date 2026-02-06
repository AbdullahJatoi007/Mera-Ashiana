import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/network/endpoints.dart';
import 'package:mera_ashiana/services/auth/login_service.dart';

class FavoriteService {
  // Using Set for O(1) lookups. ValueNotifier triggers UI on value change.
  static ValueNotifier<Set<int>> favoriteIds = ValueNotifier<Set<int>>({});
  static Map<int, PropertyModel> favoritesMap = {};

  // NEW: reactive count
  static ValueNotifier<int> favoriteIdsCount = ValueNotifier<int>(0);

  static Future<bool> toggleFavorite(
    int propertyId,
    bool currentlyLiked, {
    PropertyModel? propertyData,
  }) async {
    final cookie = await LoginService.getAuthCookie();
    if (cookie == null || cookie.isEmpty) {
      throw 'Authentication required. Please log in.';
    }

    final action = currentlyLiked ? 'unlike' : 'like';
    final url = Uri.parse(
      currentlyLiked
          ? Endpoints.unlikeProperty(propertyId)
          : Endpoints.likeProperty(propertyId),
    );

    try {
      final response = currentlyLiked
          ? await http.delete(
              url,
              headers: {'Cookie': cookie, 'Accept': 'application/json'},
            )
          : await http.post(
              url,
              headers: {'Cookie': cookie, 'Accept': 'application/json'},
            );

      debugPrint("FAV API [${response.statusCode}]: ${response.body}");

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
      debugPrint("Favorite Service Error: $e");
      rethrow;
    }
  }

  static Future<void> fetchMyFavorites() async {
    final cookie = await LoginService.getAuthCookie();
    if (cookie == null) return;

    try {
      final response = await http.get(
        Uri.parse(Endpoints.myFavorites),
        headers: {'Cookie': cookie, 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> favList = decoded['data'] ?? [];

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
      }
    } catch (e) {
      debugPrint("Fetch Favorites Error: $e");
    }
  }

  // NEW: keep count in sync
  static void _updateCount() {
    favoriteIdsCount.value = favoriteIds.value.length;
  }
}
