import 'package:url_launcher/url_launcher.dart';
import 'package:mera_ashiana/data/services/auth/auth_config.dart';
import 'package:mera_ashiana/data/services/profile_service.dart';
import 'package:mera_ashiana/data/services/agency_service.dart';

class ProfileController {
  static Future<List<dynamic>> fetchAllData() async {
    // 🚨 FIX: Execute requests sequentially to avoid 401 refresh race conditions

    // 1. Fetch profile first. If the token is expired, the interceptor will
    //    catch it here, pause, refresh the token, and then return the profile.
    final profile = await ProfileService.fetchProfile(
      forceRefresh: true,
    ).timeout(AuthConfig.connectionTimeout);

    // 2. Fetch agency second. If a refresh happened in step 1, this request
    //    will automatically use the fresh token and succeed without issues.
    final agency = await AgencyService.fetchMyAgency().timeout(
      AuthConfig.connectionTimeout,
    );

    // 3. Return the results in the exact same format the UI expects
    return [profile, agency];
  }

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
