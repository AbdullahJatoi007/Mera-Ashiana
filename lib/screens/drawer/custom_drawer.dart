import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:mera_ashiana/main.dart'; // Import to access appLocale

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: <Widget>[
          const CustomDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: <Widget>[
                _buildMenuItem(
                  context,
                  loc.home,
                  Icons.home_outlined,
                  () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  context,
                  loc.myListings,
                  Icons.apartment_outlined,
                  () {},
                ),
                _buildMenuItem(
                  context,
                  loc.favorites,
                  Icons.favorite_border,
                  () {},
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 30, color: AppColors.borderGrey),
                ),

                _buildMenuItem(
                  context,
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

                // --- LANGUAGE DROPDOWN ---
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppColors.primaryNavy,
                  ),
                  title: Text(
                    loc.changeLanguage,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: appLocale.value.languageCode,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'en', child: Text(loc.english)),
                      DropdownMenuItem(value: 'ur', child: Text(loc.urdu)),
                    ],
                    onChanged: (value) {
                      if (value != null) appLocale.value = Locale(value);
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 30, color: AppColors.borderGrey),
                ),

                _buildMenuItem(
                  context,
                  loc.helpSupport,
                  Icons.help_outline,
                  () {},
                ),
                _buildMenuItem(
                  context,
                  loc.privacyPolicy,
                  Icons.security_outlined,
                  () {},
                ),
              ],
            ),
          ),
          const Divider(height: 0, color: AppColors.borderGrey),
          _buildMenuItem(
            context,
            loc.logout,
            Icons.logout,
            () {
              AuthHelper.showLogoutDialog(context);
            },
            iconColor: AppColors.errorRed,
            textColor: AppColors.errorRed,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryNavy),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
