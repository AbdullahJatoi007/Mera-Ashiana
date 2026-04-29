import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:mera_ashiana/screens/blogs_screen.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/main.dart'; // Ensure appThemeMode and appLocale are imported
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
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
                  loc.home,
                  Icons.home_outlined,
                  () => Navigator.pop(context),
                  isDark: isDark,
                ),

                ValueListenableBuilder<bool>(
                  valueListenable: AuthState.isLoggedIn,
                  builder: (context, isLoggedIn, _) {
                    return _buildMenuItem(
                      context,
                      loc.favorites,
                      Icons.favorite_border_rounded,
                      () {
                        Navigator.pop(context);
                        if (isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavouritesScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please login to access favorites"),
                            ),
                          );
                        }
                      },
                      isDark: isDark,
                    );
                  },
                ),

                _buildMenuItem(
                  context,
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

                _buildDivider(isDark),

                // 🌙 DARK MODE TOGGLE
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : AppColors.background.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: appThemeMode,
                      builder: (context, currentMode, _) {
                        return ListTile(
                          leading: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: isDark
                                ? const Color(0xFFFFD54F)
                                : Colors.orangeAccent,
                            size: 22,
                          ),
                          title: Text(
                            loc.darkMode,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Switch.adaptive(
                            value: isDark,
                            activeColor: const Color(0xFFFFD54F),
                            onChanged: (v) {
                              appThemeMode.value = v
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 🌐 Language Selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : AppColors.background.withOpacity(0.05),
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
                          color: isDark ? Colors.white70 : AppColors.textDark,
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
                          color: isDark ? Colors.white70 : AppColors.textGrey,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(loc.english),
                          ),
                          DropdownMenuItem(value: 'ur', child: Text(loc.urdu)),
                        ],
                        onChanged: (value) {
                          if (value != null) appLocale.value = Locale(value);
                        },
                      ),
                    ),
                  ),
                ),

                _buildDivider(isDark),

                _buildMenuItem(
                  context,
                  "Contact Us",
                  Icons.headset_mic_outlined,
                  () => _launchURL('https://mera-ashiana.com/contact'),
                  isDark: isDark,
                ),

                _buildMenuItem(
                  context,
                  loc.aboutUs,
                  Icons.info_outline_rounded,
                  () => _launchURL('https://mera-ashiana.com/about'),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // 🔢 VERSION INFO
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Version 1.0.3',
              style: TextStyle(
                color: isDark ? Colors.white38 : AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Divider(
        height: 1,
        color: isDark ? Colors.white12 : AppColors.borderGrey,
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
    required bool isDark,
  }) {
    final Color finalIconColor =
        iconColor ?? (isDark ? AppColors.accentYellow : AppColors.primaryNavy);
    final Color finalTextColor =
        textColor ?? (isDark ? Colors.white70 : AppColors.textDark);

    return ListTile(
      leading: Icon(icon, color: finalIconColor, size: 22),
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
