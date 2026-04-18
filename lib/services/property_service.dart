import '../models/listing_model.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';
import 'package:flutter/foundation.dart';

class PropertyService {
  /// Fetches properties with optional [filters]
  /// If filters are provided, they are sent as query parameters (?key=value)
  static Future<List<Listing>> fetchProperties({Map<String, dynamic>? filters}) async {
    try {
      // ✅ This now works perfectly with the updated ApiClient.get
      final response = await ApiClient.get(
        Endpoints.listings,
        queryParameters: filters,
      );

      // Accessing the 'data' key with extra safety checks.
      // We check if the response is a Map before trying to access the 'data' key.
      final List rawData = response.data is Map
          ? (response.data['data'] ?? [])
          : [];

      return rawData.map((e) => Listing.fromJson(e)).toList();
    } catch (e) {
      debugPrint('PropertyService Error: $e');
      rethrow;
    }
  }
}