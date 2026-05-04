import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../models/agency_model.dart';
import '../models/user_model.dart';
import 'profile_service.dart';

class AgencyService {
  static Future<Agency?> fetchMyAgency() async {
    try {
      // 🚨 FIX: Added a strict 5-second timeout.
      // If the backend hangs, Flutter fails fast and loads the UI anyway!
      final response = await ApiClient.get(
        Endpoints.myAgency,
      ).timeout(const Duration(seconds: 5));

      final data = response.data;

      if (data['data'] != null) {
        return Agency.fromJson(data['data']);
      } else if (data['agency'] != null) {
        return Agency.fromJson(data['agency']);
      } else if (data['agencies'] != null &&
          (data['agencies'] as List).isNotEmpty) {
        return Agency.fromJson(data['agencies'][0]);
      }
      return null;
    } catch (e) {
      debugPrint(
        "Fetch My Agency Error (Likely no agency or backend timeout): $e",
      );
      return null;
    }
  }

  static Future<Map<String, dynamic>> registerAgency({
    required String agencyName,
    required String email,
    required String description,
    required String phone,
    required String address,
    File? logoFile,
  }) async {
    try {
      final User user = await ProfileService.fetchProfile();

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

      final response = await ApiClient.post(Endpoints.agency, data: formData);
      final result = response.data;

      return {
        "success": true,
        "message": result['message'] ?? "Agency registered successfully",
        "agency": result['data'] != null
            ? Agency.fromJson(result['data'])
            : (result['agency'] != null
                  ? Agency.fromJson(result['agency'])
                  : null),
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
