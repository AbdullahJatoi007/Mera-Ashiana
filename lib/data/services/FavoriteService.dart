import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mera_ashiana/core/network/api_client.dart';
import 'package:mera_ashiana/core/network/endpoints.dart';
import '../models/listing_model.dart';

class FavoriteService {
  static final ValueNotifier<Set<int>> favoriteIds = ValueNotifier({});
  static final ValueNotifier<int> favoriteIdsCount = ValueNotifier(0);
  static final Map<int, Listing> favoritesMap = {};

  static const String _storageKey = "cached_favorites_id_list";

  /// 🌟 CALL THIS IN main.dart TO LOAD ID CACHE INSTANTLY ON APP STARTUP
  static Future<void> initFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? cachedIds = prefs.getStringList(_storageKey);

      if (cachedIds != null) {
        final Set<int> loadedIds = cachedIds.map((id) => int.parse(id)).toSet();
        favoriteIds.value = loadedIds;
        favoriteIdsCount.value = loadedIds.length;
      }
    } catch (e) {
      debugPrint("Error loading cached favorite IDs: $e");
    }
  }

  /// 🌟 CALL THIS ON FavouritesScreen PULL-TO-REFRESH OR AFTER LOGIN SUCCESS
  /// Uses ApiClient so the auth interceptor attaches the access token.
  static Future<void> fetchMyFavorites() async {
    try {
      final response = await ApiClient.get(Endpoints.myFavorites);
      final List<dynamic> serverData = response.data['data'] ?? [];

      final Set<int> loadedIds = {};
      favoritesMap.clear();

      for (var item in serverData) {
        final listing = Listing.fromJson(item as Map<String, dynamic>);
        loadedIds.add(listing.id);
        favoritesMap[listing.id] = listing;
      }

      favoriteIds.value = loadedIds;
      favoriteIdsCount.value = loadedIds.length;

      // Sync local storage IDs with database reality
      await _saveToDisk();
    } on DioException catch (e) {
      debugPrint(
        "❌ [FAVORITES] fetch failed ${e.response?.statusCode}: ${e.response?.data}",
      );
    } catch (e) {
      debugPrint("Failed to load or sync favorites from remote database: $e");
    }
  }

  /// 🌟 TOGGLE FAVORITE (OPTIMISTIC UI, WITH ROLLBACK ON FAILURE)
  /// Returns the resulting favorited state. On network/server failure the
  /// optimistic change is rolled back so the UI never lies about server state.
  /// Throws on failure — callers should catch this and show feedback.
  static Future<bool> toggleFavorite(int id, {Listing? listingData}) async {
    final wasFav = favoriteIds.value.contains(id);
    final Listing? previousListingData = favoritesMap[id];

    _applyLocalToggle(id, toFavorited: !wasFav, listingData: listingData);
    await _saveToDisk();

    try {
      final response = await ApiClient.post(Endpoints.likeListing(id));

      // Trust the server's own reported state if it sends one back,
      // e.g. { "liked": true }. Falls back to our optimistic guess.
      final serverLiked = response.data is Map
          ? response.data['liked'] as bool?
          : null;
      final finalState = serverLiked ?? !wasFav;

      if (finalState != !wasFav) {
        // Server disagreed with our optimistic guess — reconcile.
        _applyLocalToggle(
          id,
          toFavorited: finalState,
          listingData: listingData,
        );
        await _saveToDisk();
      }

      return finalState;
    } on DioException catch (e) {
      debugPrint(
        "❌ [FAVORITES] toggle failed ${e.response?.statusCode}: ${e.response?.data}",
      );
      // Roll back the optimistic update — the server never persisted it.
      _applyLocalToggle(
        id,
        toFavorited: wasFav,
        listingData: previousListingData,
      );
      await _saveToDisk();
      rethrow;
    } catch (e) {
      debugPrint("Network error syncing favorite change to server: $e");
      _applyLocalToggle(
        id,
        toFavorited: wasFav,
        listingData: previousListingData,
      );
      await _saveToDisk();
      rethrow;
    }
  }

  static void _applyLocalToggle(
    int id, {
    required bool toFavorited,
    Listing? listingData,
  }) {
    final current = Set<int>.from(favoriteIds.value);

    if (toFavorited) {
      current.add(id);
      if (listingData != null) {
        favoritesMap[id] = listingData;
      }
    } else {
      current.remove(id);
      favoritesMap.remove(id);
    }

    favoriteIds.value = current;
    favoriteIdsCount.value = current.length;
  }

  /// 🔧 Local Private persistence utility (Saves IDs as safe string types)
  static Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> stringIds = favoriteIds.value
          .map((id) => id.toString())
          .toList();
      await prefs.setStringList(_storageKey, stringIds);
    } catch (e) {
      debugPrint("Error updating shared_preferences storage stack: $e");
    }
  }
}
