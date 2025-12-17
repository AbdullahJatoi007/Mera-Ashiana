import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:flutter/material.dart';

// Note: Assuming CustomDrawerHeader is in a separate file, but using it here
// import 'package:ashiana/screens/drawer/widgets/drawer_header.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _onMenuItemTap(BuildContext context, String title) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title tapped!')));
  }

  void _onLogout(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out!')));
  }

  // Helper widget using standard ListTile for menu consistency
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // 1. Header (No SafeArea needed here if Drawer is the root)
          const CustomDrawerHeader(),

          // 2. Menu Items
          Expanded(
            child: ListView(
              // Using ListView is better than SingleChildScrollView + Column
              padding: EdgeInsets.zero,
              // To remove default ListView top padding
              children: <Widget>[
                // --- Core App Features ---
                _buildMenuItem(
                  context: context,
                  title: 'Home',
                  icon: Icons.home_outlined,
                  onTap: () => _onMenuItemTap(context, 'Home'),
                ),
                _buildMenuItem(
                  context: context,
                  title: 'My Listings',
                  icon: Icons.apartment_outlined,
                  onTap: () => _onMenuItemTap(context, 'My Listings'),
                ),
                _buildMenuItem(
                  context: context,
                  title: 'Favorites',
                  icon: Icons.favorite_border,
                  onTap: () => _onMenuItemTap(context, 'Favorites'),
                ),
                _buildMenuItem(
                  context: context,
                  title: 'Messages',
                  icon: Icons.chat_bubble_outline,
                  onTap: () => _onMenuItemTap(context, 'Messages'),
                ),

                const Divider(height: 20, thickness: 1), // Standard Divider
                // --- Utility & Settings ---
                _buildMenuItem(
                  context: context,
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  onTap: () => _onMenuItemTap(context, 'Settings'),
                ),

                // --- Legal & Support ---
                _buildMenuItem(
                  context: context,
                  title: 'Help & Support',
                  icon: Icons.help_outline,
                  onTap: () => _onMenuItemTap(context, 'Help & Support'),
                ),
                _buildMenuItem(
                  context: context,
                  title: 'Terms & Conditions',
                  icon: Icons.rule_outlined,
                  onTap: () => _onMenuItemTap(context, 'Terms & Conditions'),
                ),
                _buildMenuItem(
                  context: context,
                  title: 'Privacy Policy',
                  icon: Icons.security_outlined,
                  onTap: () => _onMenuItemTap(context, 'Privacy Policy'),
                ),
                _buildMenuItem(
                  context: context,
                  title: 'Language',
                  icon: Icons.language_outlined,
                  onTap: () => _onMenuItemTap(context, 'Language'),                )
              ],
            ),
          ),

          // 3. Footer / Logout
          const Divider(height: 0, thickness: 1),
          ListTile(
            // Using ListTile for polished footer/logout
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _onLogout(context),
          ),
          const SizedBox(height: 16), // Bottom padding
        ],
      ),
    );
  }
}