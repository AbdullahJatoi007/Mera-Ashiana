import '../models/listing_model.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';
import 'package:flutter/foundation.dart';

class PropertyService {
  static Future<List<Listing>> fetchProperties() async {
    try {
      final response = await ApiClient.get(Endpoints.listings);
      final List rawData = response.data['data'] ?? [];
      return rawData.map((e) => Listing.fromJson(e)).toList();
    } catch (e) {
      debugPrint('PropertyService Error: $e');
      rethrow;
    }
  }
}