import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_exceptions.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Future<void> write({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw AuthException('Failed to save secure data');
    }
  }

  static Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw AuthException('Failed to read secure data');
    }
  }

  static Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw AuthException('Failed to delete secure data');
    }
  }

  static Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw AuthException('Failed to clear secure storage');
    }
  }
}