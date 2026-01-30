import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:mera_ashiana/screens/blogs_screen.dart';
import 'package:mera_ashiana/screens/my_listings_screen.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/main.dart';
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
      backgroundColor: isDark ? AppColors.textDark : AppColors.white,
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
                _buildMenuItem(
                  context,
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

                _buildDivider(),

                _buildMenuItem(
                  context,
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

                // Language Selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.textDark.withOpacity(0.1)
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
                          color: isDark
                              ? AppColors.white70
                              : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        dropdownColor: isDark
                            ? AppColors.textDark
                            : AppColors.white,
                        value: appLocale.value.languageCode,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDark
                              ? AppColors.white70
                              : AppColors.textGrey,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              loc.english,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.white70
                                    : AppColors.textDark,
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
                                    ? AppColors.white70
                                    : AppColors.textDark,
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

                _buildDivider(),

                _buildMenuItem(
                  context,
                  loc.helpSupport,
                  Icons.help_outline_rounded,
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

          // Logout Section — only show if logged in
          ValueListenableBuilder<bool>(
            valueListenable: AuthState.isLoggedIn,
            builder: (context, isLoggedIn, _) {
              if (!isLoggedIn) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.errorRed.withOpacity(0.1)
                      : AppColors.errorRed.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildMenuItem(
                  context,
                  loc.logout,
                  Icons.logout_rounded,
                  () => AuthHelper.showLogoutDialog(context),
                  iconColor: AppColors.errorRed,
                  textColor: AppColors.errorRed,
                  isDark: isDark,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Divider(height: 1, color: AppColors.borderGrey),
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
        textColor ?? (isDark ? AppColors.white70 : AppColors.textDark);

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
