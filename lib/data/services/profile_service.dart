import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../data/services/auth/secure_storage_service.dart';
import '../models/user_model.dart';

class ProfileService {
  static User? _cachedUser;

  static void clearCache() => _cachedUser = null;

  static Future<User?> fetchProfile({bool forceRefresh = false}) async {
    final token = await SecureStorageService.read(key: 'access_token');

    // FIX: if user is logged out, do not call API
    if (token == null) {
      _cachedUser = null;
      return null;
    }

    if (_cachedUser != null && !forceRefresh) return _cachedUser!;

    final response = await ApiClient.get(Endpoints.profile);

    _cachedUser = User.fromJson(response.data['user']);
    return _cachedUser!;
  }

  static Future<bool> updateProfile({
    required String name,
    required String phone,
    File? imageFile,
  }) async {
    try {
      Map<String, dynamic> map = {'username': name, 'phone': phone};

      if (imageFile != null) {
        map['profile_pic'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(map);

      // Use .patch and add a receiveTimeout just for this call
      final response = await ApiClient.dio
          .patch(
            Endpoints.updateProfile,
            data: formData,
            options: Options(
              contentType: 'multipart/form-data',
              // Some backends need this explicitly set for PATCH + Files
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ),
          )
          .timeout(const Duration(seconds: 15)); // 🚨 Kill the hang after 15s

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearCache();
        await fetchProfile(forceRefresh: true);
        return true;
      }

      debugPrint("Update Failed with status: ${response.statusCode}");
      return false;
    } catch (e) {
      debugPrint("Update Profile Service Error: $e");
      return false; // Crucial: ensure we return so the UI can hide the loader
    }
  }

  static Future<String?> sendEmailChangeOtp(String newEmail) async {
    try {
      final response = await ApiClient.post(
        Endpoints.sendEmailOtp,
        data: {'email': newEmail},
      );
      return response.statusCode == 200 ? null : "Failed to send code";
    } catch (e) {
      return e.toString();
    }
  }

  static Future<bool> verifyEmailChange(String otp) async {
    try {
      final response = await ApiClient.post(
        Endpoints.verifyEmailChange,
        data: {'otp': otp},
      );
      if (response.statusCode == 200) {
        clearCache(); // User email has changed, clear cache
        await fetchProfile(forceRefresh: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
