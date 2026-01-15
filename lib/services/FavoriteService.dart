import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/services/login_service.dart';

class FavoriteService {
  static const String baseUrl = "http://api.staging.mera-ashiana.com/api";
  static ValueNotifier<Set<int>> favoriteIds = ValueNotifier<Set<int>>({});
  static Map<int, Map<String, dynamic>> favoritesMap = {};

  static Future<bool> toggleFavorite(
    int propertyId,
    bool currentlyLiked,
  ) async {
    final cookie = await LoginService.getAuthCookie();

    // 1. Check if user is logged in
    if (cookie == null || cookie.isEmpty) {
      throw 'Please login to favorite properties';
    }

    final action = currentlyLiked ? 'unlike' : 'like';
    final url = Uri.parse('$baseUrl/properties/$propertyId/$action');

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

      // Log for debugging
      debugPrint("Fav Action: $action | Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedSet = Set<int>.from(favoriteIds.value);

        if (currentlyLiked) {
          updatedSet.remove(propertyId);
          favoritesMap.remove(propertyId);
        } else {
          updatedSet.add(propertyId);
        }

        favoriteIds.value = updatedSet;
        return true;
      } else if (response.statusCode == 401) {
        throw 'Your session has expired. Please log in again.';
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Favorite Error: $e");
      rethrow; // Pass the specific error message to the UI
    }
  }

  // Helper to refresh the whole list (call this on app start)
  static Future<void> fetchMyFavorites() async {
    final cookie = await LoginService.getAuthCookie();
    if (cookie == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-likes'),
        headers: {'Accept': 'application/json', 'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favList = data['data'] ?? [];
        final Set<int> ids = {};
        for (var prop in favList) {
          final id = prop['id'];
          ids.add(id);
          favoritesMap[id] = prop;
        }
        favoriteIds.value = ids;
      }
    } catch (e) {
      debugPrint("Fetch Favs Error: $e");
    }
  }
}
