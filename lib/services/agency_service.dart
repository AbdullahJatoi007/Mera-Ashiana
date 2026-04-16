import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';
import '../models/user_model.dart';
import '../models/agency_model.dart';
import 'profile_service.dart';

class AgencyService {
  /// Fetches the current user's agency details
  static Future<Agency?> fetchMyAgency() async {
    try {
      // Uses Endpoints.myAgency -> "$apiBase/agencies/me"
      final response = await ApiClient.get(Endpoints.myAgency);
      final data = response.data;

      // Handle common backend variations for single object vs list
      if (data['data'] != null) {
        // If your backend wraps the result in a 'data' key
        return Agency.fromJson(data['data']);
      } else if (data['agency'] != null) {
        return Agency.fromJson(data['agency']);
      } else if (data['agencies'] != null && (data['agencies'] as List).isNotEmpty) {
        return Agency.fromJson(data['agencies'][0]);
      }
      return null;
    } catch (e) {
      // Returning null allows the UI to show "Become an Agent" or "Create Agency"
      debugPrint("Fetch My Agency Error: $e");
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
      // Retrieve profile to associate the agency with the current user ID
      final User user = await ProfileService.fetchProfile();

      // Create FormData for multipart/form-data request
      FormData formData = FormData.fromMap({
        'agency_name': agencyName.trim(),
        'email': email.trim().toLowerCase(),
        'description': description.trim().isEmpty
            ? "No description provided"
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

      // Uses Endpoints.agency -> "$apiBase/agencies" (POST)
      final response = await ApiClient.post(
        Endpoints.agency,
        data: formData,
      );

      final result = response.data;

      return {
        "success": true,
        "message": result['message'] ?? "Agency registered successfully",
        "agency": result['data'] != null
            ? Agency.fromJson(result['data'])
            : (result['agency'] != null ? Agency.fromJson(result['agency']) : null),
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}