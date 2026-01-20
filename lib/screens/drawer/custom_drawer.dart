import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:mera_ashiana/main.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Sync with app background
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
                  () {},
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.favorites,
                  Icons.favorite_border,
                  () {},
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
                        builder: (context) => const AccountSettingsScreen(),
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
                    // Dark background for dropdown menu
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
                  () {},
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.aboutUs,
                  Icons.security_outlined,
                  () {},
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
