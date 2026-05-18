import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';

class PropertyService {
  static Future<List<Listing>> fetchProperties({
    required int page,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await ApiClient.get(
        Endpoints.listings,
        queryParameters: {...?filters, "page": page, "limit": limit},
      );

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
