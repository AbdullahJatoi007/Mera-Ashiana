import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:mera_ashiana/screens/blogs_screen.dart';
import 'package:mera_ashiana/screens/my_listings_screen.dart'; // Added
import 'package:mera_ashiana/base_screens/favourite_screen.dart'; // Added
import 'package:mera_ashiana/main.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for Help/About

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // Helper to launch external URLs
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: <Widget>[
          const CustomDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: <Widget>[
                _buildMenuItem(
                  context,
                  theme,
                  loc.home,
                  Icons.home_outlined,
                  () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.myListings,
                  Icons.apartment_outlined,
                  () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyListingsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.favorites,
                  Icons.favorite_border,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavouritesScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.blogs,
                  Icons.newspaper_outlined,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BlogsScreen()),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 30,
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.accountSettings,
                  Icons.settings_outlined,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountSettingsScreen(),
                      ),
                    );
                  },
                ),

                // Language Dropdown
                ListTile(
                  leading: Icon(Icons.language, color: colorScheme.primary),
                  title: Text(
                    loc.changeLanguage,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    dropdownColor: theme.cardColor,
                    value: appLocale.value.languageCode,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(
                          loc.english,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ur',
                        child: Text(
                          loc.urdu,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) appLocale.value = Locale(value);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 30,
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),

                _buildMenuItem(
                  context,
                  theme,
                  loc.helpSupport,
                  Icons.help_outline,
                  () => _launchURL('http://staging.mera-ashiana.com/contact'),
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.aboutUs,
                  Icons.info_outline, // Changed icon for About
                  () => _launchURL('http://staging.mera-ashiana.com/about'),
                ),
              ],
            ),
          ),
          Divider(height: 0, color: theme.dividerColor.withOpacity(0.1)),
          _buildMenuItem(
            context,
            theme,
            loc.logout,
            Icons.logout,
            () => AuthHelper.showLogoutDialog(context),
            iconColor: colorScheme.error,
            textColor: colorScheme.error,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
