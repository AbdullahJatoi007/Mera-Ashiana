import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';
import '../models/user_model.dart';

class ProfileService {
  static User? _cachedUser;

  static void clearCache() => _cachedUser = null;

  static Future<User> fetchProfile({bool forceRefresh = false}) async {
    if (_cachedUser != null && !forceRefresh) return _cachedUser!;

    final response = await ApiClient.get(Endpoints.profile);
    _cachedUser = User.fromJson(response.data['user']);
    return _cachedUser!;
  }

  static Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? imageFile,
  }) async {
    // Dio uses FormData for multipart requests
    FormData formData = FormData.fromMap({
      'username': name,
      'email': email,
      'phone': phone,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await ApiClient.post(
      Endpoints.updateProfile,
      data: formData,
    );

    if (response.statusCode == 200) {
      await fetchProfile(forceRefresh: true);
      return true;
    }
    return false;
  }
}
