import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard Scaffold structure for a screen
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _ProfileContent()),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24.0),
      children: <Widget>[
        // 1. Header Section
        _buildHeader(context, loc),

        const SizedBox(height: 12),

        // 2. Metrics Row (Listings, Favourites, Views)
        _buildMetricsRow(context, loc),

        const SizedBox(height: 12),

        // 3. Main Action Section
        _buildActionSection(context, loc),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryNavy.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zubair Ali',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'mrzubair@gmail.com',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricCard(
            count: '12',
            label: loc.listings ?? 'Listings',
            icon: Icons.apartment_outlined,
            onTap: () {},
          ),
          _MetricCard(
            count: '45',
            label: loc.favorites,
            icon: Icons.favorite_border,
            onTap: () {},
          ),
          _MetricCard(
            count: '3.2K',
            label: loc.views ?? 'Views',
            icon: Icons.bar_chart_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, AppLocalizations loc) {
    const String appVersion = '1.0.3 (23)';

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: AppColors.borderGrey),
        ),

        _buildListTile(
          context,
          title: loc.accountSettings,
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountSettingsScreen(),
              ),
            );
          },
        ),
        _buildListTile(
          context,
          title: loc.paymentMethods ?? 'Payment Methods',
          icon: Icons.credit_card_outlined,
          onTap: () {},
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: AppColors.borderGrey),
        ),

        _buildListTile(
          context,
          title: loc.helpSupport,
          icon: Icons.help_outline,
          onTap: () {},
        ),
        _buildListTile(
          context,
          title: loc.contactUs ?? 'Contact Us',
          icon: Icons.mail_outline,
          onTap: () {},
        ),
        _buildListTile(
          context,
          title: loc.privacyPolicy,
          icon: Icons.security_outlined,
          onTap: () {},
        ),
        _buildListTile(
          context,
          title: loc.appVersion ?? 'App Version',
          icon: Icons.verified_user_outlined,
          trailingText: appVersion,
          onTap: () {},
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: AppColors.borderGrey),
        ),

        _buildListTile(
          context,
          title: loc.logout,
          icon: Icons.logout,
          color: AppColors.errorRed,
          onTap: () => _showLogoutDialog(context, loc),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
    String? trailingText,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryNavy),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: const TextStyle(color: AppColors.textGrey),
            )
          : const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textGrey,
            ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutConfirm ?? "Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.cancel,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              loc.logout,
              style: const TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String count;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderGrey),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, size: 28, color: AppColors.primaryNavy),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
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
