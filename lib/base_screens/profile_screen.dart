import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/base_screens/profile_screen.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/helpers/account_ui_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/real_estate_registration_screen.dart';
import 'package:mera_ashiana/screens/AgencyStatusScreen.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/my_listings_screen.dart';
import 'package:mera_ashiana/screens/add_listing_screen.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/services/profile_service.dart';
import 'package:mera_ashiana/services/agency_service.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/models/user_model.dart';
import 'package:mera_ashiana/models/agency_model.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mera_ashiana/services/auth/auth_config.dart';

// User metrics model - Replace hardcoded values
class UserMetrics {
  final int listingsCount;
  final int favoritesCount;
  final String viewsCount;

  const UserMetrics({
    required this.listingsCount,
    required this.favoritesCount,
    required this.viewsCount,
  });

  factory UserMetrics.empty() =>
      const UserMetrics(listingsCount: 0, favoritesCount: 0, viewsCount: '0');
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(label: 'Profile Screen', child: const _ProfileContent()),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  User? _user;
  Agency? _userAgency;
  UserMetrics _metrics = UserMetrics.empty();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
    AuthState.isLoggedIn.addListener(_handleAuthChange);
  }

  @override
  void dispose() {
    AuthState.isLoggedIn.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    if (mounted) _loadUser();
  }

  Future<void> _loadUser() async {
    if (!AuthState.isLoggedIn.value) {
      if (mounted) {
        setState(() {
          _user = null;
          _userAgency = null;
          _metrics = UserMetrics.empty();
          _isLoading = false;
          _error = null;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      // Parallel API calls for better performance
      // CHANGE THIS:
      final results = await Future.wait([
        ProfileService.fetchProfile(
          forceRefresh: true,
        ).timeout(AuthConfig.connectionTimeout),
        // Changed
        AgencyService.fetchMyAgency().timeout(AuthConfig.connectionTimeout),
        // Changed
        _fetchUserMetrics().timeout(AuthConfig.connectionTimeout),
        // Changed
      ]);

      if (mounted) {
        setState(() {
          _user = results[0] as User?;
          _userAgency = results[1] as Agency?;
          _metrics = results[2] as UserMetrics;
          _error = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _user = null;
          _error = _getUserFriendlyError(e);
          _isLoading = false;
        });
      }
    }
  }

  // Extract user metrics - Replace with actual API call
  Future<UserMetrics> _fetchUserMetrics() async {
    // TODO: Replace with actual API call
    // This is a placeholder - fetch real data from your backend
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => const UserMetrics(
        listingsCount: 12,
        favoritesCount: 45,
        viewsCount: '3.2K',
      ),
    );
  }

  String? _getUserFriendlyError(Object error) {
    if (error.toString().contains('401')) {
      return null; // Auth error - don't show
    } else if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _handleAgencyNavigation() async {
    _showLoadingDialog();

    try {
      // CHANGE THIS:
      final agency = await AgencyService.fetchMyAgency().timeout(
        AuthConfig.connectionTimeout, // Changed
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      setState(() => _userAgency = agency);

      final targetScreen = agency != null
          ? const AgencyStatusScreen()
          : const RealEstateRegistrationScreen();

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );

      _loadUser();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Failed to load agency information');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PopScope(
          canPop: false, // Prevents the back button from closing the dialog
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.accentYellow,
              semanticsLabel: 'Loading',
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Secure URL launcher with validation
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Security: Validate domain whitelist
      if (!_isAllowedDomain(uri.host)) {
        _showErrorSnackBar('Invalid URL domain');
        return;
      }

      // Security: Only allow http/https schemes
      if (!['http', 'https'].contains(uri.scheme)) {
        _showErrorSnackBar('Invalid URL scheme');
        return;
      }

      // Change LaunchMode in _launchURL
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView, // Better than externalApplication
        );
      } else {
        _showErrorSnackBar('Could not open link');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open link');
    }
  }

  // CHANGE THIS:
  bool _isAllowedDomain(String host) {
    return AuthConfig.allowedDomains.any(
      (domain) => host.endsWith(domain),
    ); // Changed
  }

  void _showLoginSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AuthenticationBottomSheet(onLoginSuccess: _loadUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryNavy,
          semanticsLabel: 'Loading profile',
        ),
      );
    }

    if (_user == null && _error == null) {
      return _buildGuestView(loc, isDark);
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return RefreshIndicator(
      color: AppColors.accentYellow,
      onRefresh: _loadUser,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          _buildHeader(_user!, isDark),
          if (_userAgency != null) _buildAgencyStatusBanner(isDark),
          const SizedBox(height: 25),
          _buildMetricsRow(loc, isDark),
          const SizedBox(height: 25),
          _buildActionSection(loc, _user?.type ?? 'user', isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGuestView(AppLocalizations loc, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Guest user icon',
              child: Icon(
                Icons.account_circle_rounded,
                size: 100,
                color: isDark
                    ? AppColors.accentYellow.withOpacity(0.2)
                    : AppColors.primaryNavy.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Profile & Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDark ? Colors.white : AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Login to view your listings and manage your account.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _showLoginSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  foregroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Semantics(
                  button: true,
                  label: 'Login or Register button',
                  child: const Text(
                    "LOGIN / REGISTER",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User user, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Semantics(
        label: 'User profile header',
        child: Row(
          children: [
            Semantics(
              label: 'Profile avatar for ${user.username}',
              child: CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.accentYellow,
                child: Text(
                  user.username.isNotEmpty
                      ? user.username[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 28,
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTypeBadge(user.type),
                    ],
                  ),
                  Semantics(
                    label: 'Email address',
                    child: Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    return Semantics(
      label: 'User type: $type',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.accentYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.accentYellow.withOpacity(0.5)),
        ),
        child: Text(
          type.toUpperCase(),
          style: const TextStyle(
            color: AppColors.accentYellow,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyStatusBanner(bool isDark) {
    final status = _userAgency!.status.toLowerCase();
    final statusColor = _getStatusColor(status);

    return Semantics(
      label: 'Agency status: $status',
      button: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: statusColor.withOpacity(0.2)),
        ),
        child: ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            _handleAgencyNavigation();
          },
          leading: Icon(
            status == 'approved' ? Icons.verified : Icons.pending,
            color: statusColor,
          ),
          title: Text(
            "Agency: ${status.toUpperCase()}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            "View dashboard",
            style: TextStyle(fontSize: 12, color: statusColor.withOpacity(0.8)),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: statusColor),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return AppColors.errorRed;
      default:
        return Colors.orange;
    }
  }

  Widget _buildMetricsRow(AppLocalizations loc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _MetricCard(
            count: _metrics.listingsCount.toString(),
            label: 'Listings',
            icon: Icons.apartment_rounded,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _MetricCard(
            count: _metrics.favoritesCount.toString(),
            label: 'Favorites',
            icon: Icons.favorite_rounded,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavouritesScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _MetricCard(
            count: _metrics.viewsCount,
            label: 'Views',
            icon: Icons.visibility_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(
    AppLocalizations loc,
    String userType,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [  _buildSettingsTile(
        title: loc.accountSettings,
        icon: Icons.manage_accounts_outlined,
        isDark: isDark,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AccountSettingsScreen(),
            ),
          );
        },
      ),
          _buildSettingsTile(
            title: 'Post Property Ad',
            icon: Icons.add_circle_outline_rounded,
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddListingScreen()),
              );
            },
          ),

          if (userType == 'agent')
            _buildSettingsTile(
              title: 'Agency Management',
              icon: Icons.business_center_outlined,
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                _handleAgencyNavigation();
              },
            ),
          _buildSettingsTile(
            title: 'My Listings',
            icon: Icons.format_list_bulleted_rounded,
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              );
            },
          ),
          _buildSettingsTile(
            title: 'About Us',
            icon: Icons.info_outline_rounded,
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              _launchURL('https://mera-ashiana.com/about');
            },
          ),
          _buildSettingsTile(
            title: loc.logout,
            icon: Icons.logout_rounded,
            isDestructive: true,
            isDark: isDark,
            onTap: () {
              HapticFeedback.mediumImpact();
              AuthHelper.showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
    required bool isDark,
  }) {
    final Color iconColor = isDestructive
        ? AppColors.errorRed
        : (isDark ? AppColors.accentYellow : AppColors.primaryNavy);

    return Semantics(
      button: true,
      label: title,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? AppColors.errorRed
                : (isDark ? Colors.white : AppColors.primaryNavy),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppColors.textGrey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            const Text(
              "Something went wrong",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? "Unknown Error",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _loadUser();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _MetricCard({
    required this.count,
    required this.label,
    required this.icon,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: onTap != null,
        label: '$count $label',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : AppColors.textGrey.withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isDark
                      ? AppColors.accentYellow
                      : AppColors.primaryNavy,
                  size: 24,
                ),
                const SizedBox(height: 10),
                Text(
                  count,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: isDark ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
