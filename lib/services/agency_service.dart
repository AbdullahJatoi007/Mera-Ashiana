import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core//api_client.dart';
import '../network/endpoints.dart';
import '../models/user_model.dart';
import '../models/agency_model.dart';
import 'profile_service.dart';

class AgencyService {
  /// Fetches the current user's agency details
  static Future<Agency?> fetchMyAgency() async {
    try {
      final response = await ApiClient.get(Endpoints.myAgency);
      final data = response.data;

      // Check if API returns 'agency' object or an 'agencies' list
      if (data['agency'] != null) {
        return Agency.fromJson(data['agency']);
      } else if (data['agencies'] != null &&
          (data['agencies'] as List).isNotEmpty) {
        return Agency.fromJson(data['agencies'][0]);
      }
      return null;
    } catch (e) {
      // We return null on error so the UI can show "Create Agency" button
      return null;
    }
  }

  /// Registers a new agency using Dio FormData
  static Future<Map<String, dynamic>> registerAgency({
    required String agencyName,
    required String email,
    required String description,
    required String phone,
    required String address,
    File? logoFile,
  }) async {
    try {
      // Get profile for user_id
      final User user = await ProfileService.fetchProfile();

      // ✅ Recommended for Play Store: Use FormData for robust file uploads
      FormData formData = FormData.fromMap({
        'agency_name': agencyName.trim(),
        'email': email.trim().toLowerCase(),
        'description': description.trim().isEmpty
            ? "No description"
            : description.trim(),
        'phone': phone.trim(),
        'address': address.trim().isEmpty ? "Not provided" : address.trim(),
        'user_id': user.id.toString(),
        if (logoFile != null)
          'logo': await MultipartFile.fromFile(
            logoFile.path,
            filename: logoFile.path.split('/').last,
          ),
      });

      final response = await ApiClient.post(
        Endpoints.registerAgency,
        data: formData,
      );
      final decoded = response.data;

      return {
        "success": true,
        "message": decoded['message'] ?? "Registered successfully",
        "agency": decoded['agency'] != null
            ? Agency.fromJson(decoded['agency'])
            : null,
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
