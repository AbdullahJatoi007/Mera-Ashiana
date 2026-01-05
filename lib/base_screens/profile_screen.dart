import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/real_estate_registration_screen.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.zero, // Start from the very top
      children: <Widget>[
        // 1. Polished Header
        _buildHeader(context, loc),

        const SizedBox(height: 20),

        // 2. Metrics (Listings, Favourites, Views)
        _buildMetricsRow(context, loc),

        const SizedBox(height: 25),

        // 3. Main Action Section
        _buildActionSection(context, loc),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        // Using a gradient makes the Navy feel deeper and more premium
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1D37), // Primary Navy
            Color(0xFF162D4D), // Slightly lighter Navy for depth
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image with Yellow Border
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC400), // Yellow border
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?u=zubair',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0A1D37),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Color(0xFF0A1D37),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // User Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zubair Ali',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'mrzubair@gmail.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Verified Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          _MetricCard(count: '12', label: 'Listings', icon: Icons.apartment),
          const SizedBox(width: 12),
          _MetricCard(count: '45', label: 'Favorites', icon: Icons.favorite),
          const SizedBox(width: 12),
          _MetricCard(
            count: '3.2K',
            label: 'Views',
            icon: Icons.remove_red_eye,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            title: loc.accountSettings,
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
           title: 'Agency Settings',
            icon: Icons.real_estate_agent_sharp,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RealEstateRegistrationScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
              title: loc.paymentMethods,
            icon: Icons.payment_outlined,
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            title: loc.helpSupport,
            icon: Icons.headset_mic_outlined,
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            title: loc.privacyPolicy,
            icon: Icons.verified_user_outlined,
            onTap: () {
              _launchURL('https://www.zameen.com/terms.html');
            },
          ),

          _buildSettingsTile(
            context,
            title: loc.logout,
            icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () {
              AuthHelper.showLogoutDialog(context);
            }
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color color = isDestructive
        ? Colors.redAccent
        : const Color(0xFF0A1D37);
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
          color: isDestructive ? Colors.redAccent : const Color(0xFF0A1D37),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

}

class _MetricCard extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;

  const _MetricCard({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0A1D37), size: 22),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFFFFC400),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
