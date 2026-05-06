import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../models/agency_model.dart';
import 'profile_service.dart';

class AgencyService {
  static Future<Agency?> fetchMyAgency() async {
    try {
      final response = await ApiClient.get(
        Endpoints.myAgency,
      ).timeout(const Duration(seconds: 8));
      final data = response.data;
      if (data == null) return null;
      if (data['data'] != null) return Agency.fromJson(data['data']);
      if (data['agency'] != null) return Agency.fromJson(data['agency']);
      if (data['id'] != null && data['agency_name'] != null)
        return Agency.fromJson(data);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      debugPrint("fetchMyAgency error: $e");
      return null;
    } catch (e) {
      debugPrint("fetchMyAgency unexpected error: $e");
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
      final user = await ProfileService.fetchProfile();
      if (user == null)
        return {"success": false, "message": "Session expired."};

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

      final response = await ApiClient.post(Endpoints.agency, data: formData);
      final result = response.data;

      debugPrint("=== registerAgency RESPONSE: $result ===");

      return {
        "success": true,
        "message": result['message'] ?? "Registered successfully",
        "agency": result['data'] != null
            ? Agency.fromJson(result['data'])
            : (result['agency'] != null
                  ? Agency.fromJson(result['agency'])
                  : null),
      };
    } catch (e) {
      debugPrint("=== registerAgency ERROR: $e ===");
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateAgency({
    String? agencyName,
    String? description,
    String? phone,
    String? email,
    String? address,
    File? logoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (agencyName != null) 'agency_name': agencyName.trim(),
        if (description != null) 'description': description.trim(),
        if (phone != null) 'phone': phone.trim(),
        if (email != null) 'email': email.trim().toLowerCase(),
        if (address != null) 'address': address.trim(),
        if (logoFile != null)
          'logo': await MultipartFile.fromFile(
            logoFile.path,
            filename: logoFile.path.split('/').last,
          ),
      });

      final response = await ApiClient.patch(
        Endpoints.myAgency,
        data: formData,
      );
      final result = response.data;

      debugPrint("=== updateAgency RESPONSE: $result ===");

      return {
        'success': true,
        'agency': result['data'] != null
            ? Agency.fromJson(result['data'])
            : (result['id'] != null ? Agency.fromJson(result) : null),
      };
    } catch (e) {
      debugPrint("=== updateAgency ERROR: $e ===");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<bool> deleteAgency() async {
    try {
      await ApiClient.delete(Endpoints.myAgency);
      return true;
    } catch (e) {
      return false;
    }
  }
}
