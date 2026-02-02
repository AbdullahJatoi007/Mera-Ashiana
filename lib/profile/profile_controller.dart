import 'package:url_launcher/url_launcher.dart';
import 'package:mera_ashiana/services/auth/auth_config.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:mera_ashiana/services/agency_service.dart';

class ProfileController {
  // Original logic for fetching profile and agency
  static Future<List<dynamic>> fetchAllData() {
    return Future.wait([
      ProfileService.fetchProfile(
        forceRefresh: true,
      ).timeout(AuthConfig.connectionTimeout),
      AgencyService.fetchMyAgency().timeout(AuthConfig.connectionTimeout),
    ]);
  }

  // Original URL launcher with domain validation
  static Future<void> launchURL(String url, Function(String) onError) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!AuthConfig.allowedDomains.any(
        (domain) => uri.host.endsWith(domain),
      )) {
        onError('Invalid URL domain');
        return;
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        onError('Could not open link');
      }
    } catch (e) {
      onError('Failed to open link');
    }
  }
}
