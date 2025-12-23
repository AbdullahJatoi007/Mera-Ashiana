import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetHelper {

  /// Check if device is connected to internet
  static Future<bool> hasInternetConnection() async {
    // Step 1: Check network (WiFi / Mobile)
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Step 2: Check actual internet access
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
