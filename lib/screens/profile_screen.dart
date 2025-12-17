import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'auth/login_screen.dart';

// --- Widget Definitions ---

// Helper for the small tappable Metric Cards
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
    final colorScheme = Theme.of(context).colorScheme;

    // Use a Card or elevated container for subtle elevation/separation
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        elevation: 1, // Subtle lift
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, size: 28, color: colorScheme.primary),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
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

// The main Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Utility method for action feedback (placeholder for navigation/logout)
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper for consistent action list tiles
  Widget _buildListTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        Color? color,
        required VoidCallback onTap,
        String? trailingText, // New parameter for App Version
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: TextStyle(color: color)),
      trailing: trailingText != null
          ? Text(
        trailingText,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      )
          : const Icon(Icons.chevron_right), // Use chevron if no trailing text
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensuring safety by using a standard Scaffold body structure
    return const Scaffold(body: SafeArea(child: _ProfileContent()));
  }
}

// Separating the content into a dedicated widget for better rendering control
class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    // Accessing parent methods/properties safely
    final ProfileScreen? parent = context
        .findAncestorWidgetOfExactType<ProfileScreen>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: colorScheme.primary.withOpacity(0.19),
            child: Icon(Icons.person, size: 50, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          // User Info and Edit Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zubair Ali', // Placeholder - to be replaced by state data
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'mrzubair@gmail.com', // Placeholder
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      parent?._showSnackBar(context, 'Edit Profile Tapped'),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, ColorScheme colorScheme) {
    final ProfileScreen? parent = context
        .findAncestorWidgetOfExactType<ProfileScreen>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricCard(
            count: '12',
            label: 'Listings',
            icon: Icons.apartment_outlined,
            onTap: () => parent?._showSnackBar(context, 'Listings Tapped'),
          ),
          _MetricCard(
            count: '45',
            label: 'Favourites',
            icon: Icons.favorite_border,
            onTap: () => parent?._showSnackBar(context, 'Favourites Tapped'),
          ),
          _MetricCard(
            count: '3.2K',
            label: 'Views',
            icon: Icons.bar_chart_outlined,
            onTap: () => parent?._showSnackBar(context, 'Views Tapped'),
          ),
        ],
      ),
    );
  }

  // UPDATED: Removed Notifications, Added Contact Us and App Version
  Widget _buildActionSection(BuildContext context) {
    final ProfileScreen? parent = context
        .findAncestorWidgetOfExactType<ProfileScreen>();

    // This is where you would typically get the version dynamically using the 'package_info_plus' package.
    const String appVersion = '1.0.3 (23)';

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),

        // --- Account Settings ---
        parent!._buildListTile(
          context,
          title: 'Account Settings',
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
        parent._buildListTile(
          context,
          title: 'Payment Methods',
          icon: Icons.credit_card_outlined,
          onTap: () => parent._showSnackBar(context, 'Payments Tapped'),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),

        // --- Support & Legal ---
        parent._buildListTile(
          context,
          title: 'Help & Support',
          icon: Icons.help_outline,
          onTap: () => parent._showSnackBar(context, 'Help Tapped'),
        ),

        // --- NEW: Contact Us ---
        parent._buildListTile(
          context,
          title: 'Contact Us',
          icon: Icons.mail_outline,
          onTap: () => parent._showSnackBar(
            context,
            'Contact Us Tapped (e.g., launch email app)',
          ),
        ),

        parent._buildListTile(
          context,
          title: 'Privacy Policy',
          icon: Icons.security_outlined,
          onTap: () => parent._showSnackBar(context, 'Privacy Tapped'),
        ),

        // --- NEW: App Version (Static Display) ---
        parent._buildListTile(
          context,
          title: 'App Version',
          icon: Icons.verified_user_outlined,
          trailingText: appVersion, // Shows version number on the right
          onTap: () {
            // Optional: Show build details or copyright info on tap
            parent._showSnackBar(context, 'Version ${appVersion} Information');
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),

        // --- Logout ---
        parent._buildListTile(
          context,
          title: 'Logout',
          icon: Icons.logout,
          color: Theme.of(context).colorScheme.error,
          onTap: () {
            // 1. Show a confirmation dialog (Optional but recommended)
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Close dialog
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // 2. Navigate and Clear Stack
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                              (route) => false, // This removes all previous screens
                        );
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(color: AppColors.errorRed),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use a ListView for guaranteed scrollability and efficient rendering
    return ListView(
      padding: const EdgeInsets.only(bottom: 24.0),
      children: <Widget>[
        // 1. Header
        _buildHeader(context, colorScheme),

        const SizedBox(height: 12),

        // 2. Metrics
        _buildMetricsRow(context, colorScheme),

        const SizedBox(height: 12),

        // 3. Actions (includes new items)
        _buildActionSection(context),
      ],
    );
  }
}