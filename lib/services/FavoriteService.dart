import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';

class FavoriteService {
  static final ValueNotifier<Set<int>> favoriteIds = ValueNotifier({});

  // FIX: must use Listing (not ListingModel)
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

    favoriteIds.value = current;

    return !isFav;
  }
}