import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';

class FavoriteService {
  // 1. Your existing set of IDs
  static final ValueNotifier<Set<int>> favoriteIds = ValueNotifier({});

  // 2. NEW: Add this notifier for the count so ProfileScreen can read it
  static final ValueNotifier<int> favoriteIdsCount = ValueNotifier(0);

  static final Map<int, Listing> favoritesMap = {};

  static Future<void> fetchMyFavorites() async {
    // optional: implement API later
    return;
  }

  static Future<bool> toggleFavorite(
      int id, {
        Listing? listingData,
      }) async {
    final current = Set<int>.from(favoriteIds.value);
    final isFav = current.contains(id);

    if (isFav) {
      current.remove(id);
      favoritesMap.remove(id);
    } else {
      current.add(id);
      if (listingData != null) {
        favoritesMap[id] = listingData;
      }
    }

    // 3. Update BOTH notifiers
    favoriteIds.value = current;
    favoriteIdsCount.value = current.length; // ✅ This fixes the build error

    return !isFav;
  }
}