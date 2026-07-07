import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/features/profile/profile_controller.dart';
import 'package:mera_ashiana/features/profile/widgets/profile_header.dart';
import 'package:mera_ashiana/features/auth/auth_state.dart';
import 'package:mera_ashiana/data/services/listing_service.dart';
import 'package:mera_ashiana/data/services/FavoriteService.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';
import 'package:mera_ashiana/features/profile/screens/account_settings_screen.dart';
import 'package:mera_ashiana/features/properties/screens/add_listing_screen.dart';
import 'package:mera_ashiana/features/properties/screens/my_listings_screen.dart';
import 'package:mera_ashiana/features/properties/screens/favourite_screen.dart';
import 'package:mera_ashiana/features/agency/AgencyStatusScreen.dart';
import 'package:mera_ashiana/features/agency/agency_registration_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/agency_model.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/helpers/auth_helper.dart';
import '../../../shared/helpers/internet_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  Agency? _userAgency;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMsg = '';

  Timer? _internetTimer;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    AuthState.isLoggedIn.addListener(_handleAuthChange);

    _internetTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final connected = await InternetHelper.hasInternetConnection();
      if (connected && _wasOffline) {
        _wasOffline = false;
        _loadUser();
      } else if (!connected) {
        _wasOffline = true;
      }
    });
  }

  @override
  void dispose() {
    AuthState.isLoggedIn.removeListener(_handleAuthChange);
    _internetTimer?.cancel();
    super.dispose();
  }

  void _handleAuthChange() {
    if (mounted) _loadUser();
  }

  Future<void> _loadUser() async {
    // Basic Auth Check - If not logged in, show Guest View immediately
    if (!AuthState.isLoggedIn.value) {
      if (mounted) {
        setState(() {
          _user = null;
          _userAgency = null;
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    // Only show the full-screen spinner the very first time (no cached user
    // yet). On repeat visits / pull-to-refresh, keep showing the existing UI
    // (with its already-cached avatar) and refresh quietly in the background.
    if (mounted && _user == null) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMsg = '';
      });
    }

    try {
      // Reverting to your original controller call
      final results = await ProfileController.fetchAllData();

      if (!mounted) return;

      final userObj = results[0] as User?;
      final agencyObj = results[1] as Agency?;

      setState(() {
        _user = userObj;
        // Fix: Detect 'agency' type from backend
        _userAgency = (userObj?.type?.toLowerCase() == 'agency')
            ? agencyObj
            : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Only show the error view if we have nothing at all to display.
        // If a cached user already exists, keep showing it instead of
        // wiping the screen on a transient network error.
        _hasError = _user == null;
        _errorMsg = "Failed to load profile. Please check your session.";
      });
    }
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

  void _handleAgencyNavigation() {
    // Show status screen if user is agency type OR already has an agency object
    final isAgencyUser = _user?.type?.toLowerCase() == 'agency';
    final target = (_userAgency != null || isAgencyUser)
        ? const AgencyStatusScreen()
        : const RealEstateRegistrationScreen();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => target),
    ).then((_) => _loadUser());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: RefreshIndicator(
        color: AppColors.accentYellow,
        onRefresh: _loadUser,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (_isLoading && _user == null)
              SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryNavy,
                  ),
                ),
              )
            else if (_hasError && _user == null)
              _buildErrorView()
            else if (_user == null)
              SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: _buildGuestView(isDark),
              )
            else ...[
              ProfileHeader(user: _user!),
              if (_user?.type?.toLowerCase() == 'agency' && _userAgency != null)
                _buildAgencyStatusBanner(isDark),
              const SizedBox(height: 25),
              _buildMetricsRow(isDark),
              const SizedBox(height: 25),
              _buildActionSection(loc, _user?.type ?? '', isDark),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  // ... (Other UI Widgets: _buildErrorView, _buildGuestView, _buildAgencyStatusBanner remain same)

  Widget _buildErrorView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - kToolbarHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMsg),
            TextButton(onPressed: _loadUser, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_rounded,
              size: 100,
              color: isDark
                  ? Colors.white10
                  : AppColors.primaryNavy.withOpacity(0.1),
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
                ),
                child: const Text(
                  "LOGIN / REGISTER",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgencyStatusBanner(bool isDark) {
    final status = _userAgency?.status.toLowerCase() ?? 'pending';
    final statusColor = status == 'approved'
        ? Colors.green
        : (status == 'rejected' ? AppColors.errorRed : Colors.orange);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: _handleAgencyNavigation,
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
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: statusColor),
      ),
    );
  }

  Widget _buildMetricsRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMetricCard(
            notifier: ListingService.myListingsCount,
            label: 'My Properties',
            subLabel: _user?.type?.toLowerCase() == 'agency'
                ? "Check Status"
                : "View Ads",
            icon: Icons.holiday_village_rounded,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyListingsScreen()),
            ),
          ),
          const SizedBox(width: 12),
          _buildMetricCard(
            notifier: FavoriteService.favoriteIdsCount,
            label: 'Favorites',
            subLabel: "Saved Items",
            icon: Icons.favorite_rounded,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavouritesScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required ValueNotifier<int> notifier,
    required String label,
    required String subLabel,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ValueListenableBuilder<int>(
          valueListenable: notifier,
          builder: (context, count, _) => Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : AppColors.textGrey.withOpacity(0.2),
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
                  count.toString(),
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
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            loc.accountSettings,
            Icons.manage_accounts_outlined,
            isDark,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
            ),
          ),
          _buildSettingsTile(
            'Post Property Ad',
            Icons.add_circle_outline_rounded,
            isDark,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddListingScreen()),
            ),
          ),

          // THE KEY FIX: Checking for 'agency' instead of 'agent'
          if (userType.toLowerCase() == 'agency')
            _buildSettingsTile(
              'Agency Management',
              Icons.business_center_outlined,
              isDark,
              _handleAgencyNavigation,
            ),

          _buildSettingsTile(
            'About Us',
            Icons.info_outline_rounded,
            isDark,
            () => ProfileController.launchURL(
              'https://mera-ashiana.com/about',
              (msg) {},
            ),
          ),
          _buildSettingsTile(
            loc.logout,
            Icons.logout_rounded,
            isDark,
            () => AuthHelper.showLogoutDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    bool isDark,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.errorRed
        : (isDark ? AppColors.accentYellow : AppColors.primaryNavy);
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
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
    );
  }
}
