import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:mera_ashiana/screens/blogs_screen.dart';
import 'package:mera_ashiana/screens/my_listings_screen.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/main.dart';
import 'package:url_launcher/url_launcher.dart';

// Brand Palette
class AppColors {
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color white = Colors.white;
  static const Color textGrey = Color(0xFF757575);
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      // In dark mode, we use a deep surface color; in light mode, pure white
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.white,
      child: Column(
        children: <Widget>[
          const CustomDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: <Widget>[
                _buildMenuItem(
                  context,
                  theme,
                  loc.home,
                  Icons.home_outlined,
                  () => Navigator.pop(context),
                  isDark: isDark,
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.myListings,
                  Icons.apartment_outlined,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyListingsScreen(),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.favorites,
                  Icons.favorite_border_rounded,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavouritesScreen(),
                      ),
                    );
                  },
                  isDark: isDark,
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
                  isDark: isDark,
                ),

                _buildDivider(theme),

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
                  isDark: isDark,
                ),

                // Polished Language Selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.language_rounded,
                        color: isDark
                            ? AppColors.accentYellow
                            : AppColors.primaryNavy,
                        size: 22,
                      ),
                      title: Text(
                        loc.changeLanguage,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        dropdownColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        value: appLocale.value.languageCode,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDark ? Colors.white54 : AppColors.textGrey,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              loc.english,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primaryNavy,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ur',
                            child: Text(
                              loc.urdu,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primaryNavy,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) appLocale.value = Locale(value);
                        },
                      ),
                    ),
                  ),
                ),

                _buildDivider(theme),

                _buildMenuItem(
                  context,
                  theme,
                  loc.helpSupport,
                  Icons.help_outline_rounded,
                  () => _launchURL('http://staging.mera-ashiana.com/contact'),
                  isDark: isDark,
                ),
                _buildMenuItem(
                  context,
                  theme,
                  loc.aboutUs,
                  Icons.info_outline_rounded,
                  () => _launchURL('http://staging.mera-ashiana.com/about'),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Logout Section
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.red.withOpacity(0.1)
                  : Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildMenuItem(
              context,
              theme,
              loc.logout,
              Icons.logout_rounded,
              () => AuthHelper.showLogoutDialog(context),
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Divider(height: 1, color: theme.dividerColor.withOpacity(0.05)),
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
    required bool isDark,
  }) {
    // Logic for visibility in Dark Mode
    final Color finalIconColor =
        iconColor ?? (isDark ? AppColors.accentYellow : AppColors.primaryNavy);
    final Color finalTextColor =
        textColor ?? (isDark ? Colors.white : AppColors.primaryNavy);

    return ListTile(
      leading: Icon(icon, color: finalIconColor, size: 22),
      visualDensity: const VisualDensity(vertical: -1),
      title: Text(
        title,
        style: TextStyle(
          color: finalTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
