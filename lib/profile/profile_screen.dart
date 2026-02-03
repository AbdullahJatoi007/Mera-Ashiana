import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/profile/widgets/profile_header.dart';
import 'package:mera_ashiana/profile/profile_controller.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/services/listing_service.dart';
import 'package:mera_ashiana/services/FavoriteService.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/models/user_model.dart';
import 'package:mera_ashiana/models/agency_model.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/add_listing_screen.dart';
import 'package:mera_ashiana/screens/my_listings_screen.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/screens/AgencyStatusScreen.dart';
import 'package:mera_ashiana/screens/agency_registration_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  Agency? _userAgency;
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
      return;
    }
    if (mounted) setState(() => _isLoading = true);
    try {
      final results = await ProfileController.fetchAllData();
      if (mounted) {
        setState(() {
          _user = results[0] as User?;
          _userAgency = results[1] as Agency?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
    final target = _userAgency != null
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

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryNavy),
      );
    }
    if (_user == null) return _buildGuestView(isDark);

    return RefreshIndicator(
      color: AppColors.accentYellow,
      onRefresh: _loadUser,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProfileHeader(user: _user!),
          if (_userAgency != null) _buildAgencyStatusBanner(isDark),
          const SizedBox(height: 25),
          _buildMetricsRow(isDark),
          const SizedBox(height: 25),
          _buildActionSection(loc, _user!.type, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAgencyStatusBanner(bool isDark) {
    final status = _userAgency!.status.toLowerCase();
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
        subtitle: const Text("View dashboard", style: TextStyle(fontSize: 12)),
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
            ListingService.myListingsCount,
            'Listings',
            Icons.apartment_rounded,
            isDark,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _buildMetricCard(
            FavoriteService.favoriteIdsCount,
            'Favorites',
            Icons.favorite_rounded,
            isDark,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavouritesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    ValueNotifier<int> notifier,
    String label,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
          if (userType == 'agent')
            _buildSettingsTile(
              'Agency Management',
              Icons.business_center_outlined,
              isDark,
              () => _handleAgencyNavigation(),
            ),
          _buildSettingsTile(
            'My Listings',
            Icons.format_list_bulleted_rounded,
            isDark,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyListingsScreen()),
            ),
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
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
            const SizedBox(height: 12),
            const Text(
              "Login to view your listings and manage your account.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
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
}
