import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mera_ashiana/network/endpoints.dart';

class InternetHelper {
  /// Checks whether the device has active internet access
  /// Safe for Google Play (no background polling, no tracking)
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // No network at all
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      final uri = Uri.parse(Endpoints.apiBase);

      final result = await InternetAddress.lookup(
        uri.host,
      ).timeout(const Duration(seconds: 3));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
