import 'package:flutter/material.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  User? user;
  Agency? userAgency;
  bool isLoading = true;
  String? error;

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
    if (mounted) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    if (!AuthState.isLoggedIn.value) {
      if (mounted) {
        setState(() {
          user = null;
          userAgency = null;
          isLoading = false;
          error = null;
        });
      }
      return;
    }

    if (mounted) setState(() => isLoading = true);
    try {
      final profile = await ProfileService.fetchProfile(forceRefresh: true);
      final agency = await AgencyService.fetchMyAgency();

      if (mounted) {
        setState(() {
          user = profile;
          userAgency = agency;
          error = null;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          user = null;
          error = e.toString().contains('401') ? null : e.toString();
          isLoading = false;
        });
      }
    }
  }

  // ================= MERGED NAVIGATION LOGIC =================
  void _handleAgencyNavigation() async {
    // 1. Show a loading indicator while we check the latest status
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Always fetch latest from server to be 100% sure
    final agency = await AgencyService.fetchMyAgency();

    if (!mounted) return;
    Navigator.pop(context); // Remove loading indicator

    if (mounted) {
      setState(() => userAgency = agency);
    }

    if (agency != null) {
      // If agency exists, go to Status Screen
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AgencyStatusScreen()),
      ).then((_) => _loadUser()); // Refresh profile when coming back
    } else {
      // If NO agency, go to Registration
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RealEstateRegistrationScreen()),
      ).then((_) => _loadUser()); // This re-runs _loadUser() to update UI
    }
  }

  // ===========================================================

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthenticationBottomSheet(
        onLoginSuccess: () {
          _loadUser();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (user == null && error == null) return _buildGuestView(loc);
    if (error != null) return _buildErrorView();

    return RefreshIndicator(
      onRefresh: _loadUser,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          _buildHeader(user!),
          if (userAgency != null) _buildAgencyStatusBanner(),
          const SizedBox(height: 20),
          _buildMetricsRow(loc),
          const SizedBox(height: 25),
          _buildActionSection(loc, user?.type ?? 'user'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAgencyStatusBanner() {
    final status = userAgency!.status.toLowerCase();
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending_actions_rounded;

    if (status == 'approved') {
      statusColor = Colors.green;
      statusIcon = Icons.verified_rounded;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: _handleAgencyNavigation,
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Agency Status: ${status.toUpperCase()}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    "Tap to view agency dashboard",
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView(AppLocalizations loc) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            const Text(
              "Profile & Settings",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              "Login to view your listings, manage your account, and see your saved properties.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "LOGIN / REGISTER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: colorScheme.secondary,
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTypeBadge(user.type),
                  ],
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricsRow(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          _MetricCard(
            count: '12',
            label: 'Listings',
            icon: Icons.apartment,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyListingsScreen()),
            ),
          ),
          const SizedBox(width: 12),
          _MetricCard(
            count: '45',
            label: 'Favorites',
            icon: Icons.favorite,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavouritesScreen()),
            ),
          ),
          const SizedBox(width: 12),
          const _MetricCard(
            count: '3.2K',
            label: 'Views',
            icon: Icons.remove_red_eye,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(AppLocalizations loc, String userType) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            title: 'Post Property Ad',
            icon: Icons.add_business_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddListingScreen()),
            ),
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            title: loc.accountSettings,
            icon: Icons.person_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
            ),
          ),
          _buildSettingsTile(
            title: 'My Listings',
            icon: Icons.list_alt_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyListingsScreen()),
            ),
          ),
          if (userType == 'agent')
            _buildSettingsTile(
              title: 'Agency Management',
              icon: Icons.business_outlined,
              onTap: _handleAgencyNavigation,
            ),
          _buildSettingsTile(
            title: loc.paymentMethods,
            icon: Icons.payment_outlined,
            onTap: () {},
          ),
          _buildSettingsTile(
            title: loc.helpSupport,
            icon: Icons.headset_mic_outlined,
            onTap: () => _launchURL('http://staging.mera-ashiana.com/contact'),
          ),
          _buildSettingsTile(
            title: 'About Us',
            icon: Icons.info_outline,
            onTap: () => _launchURL('http://staging.mera-ashiana.com/contact'),
          ),
          _buildSettingsTile(
            title: loc.logout,
            icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () => AuthHelper.showLogoutDialog(context),
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
  }) {
    final theme = Theme.of(context);
    final Color color = isDestructive
        ? Colors.redAccent
        : theme.colorScheme.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
          color: isDestructive ? Colors.redAccent : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Something went wrong",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(error ?? "Unknown Error"),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadUser, child: const Text("Retry")),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.count,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
