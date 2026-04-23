import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/logout_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/account_settings_screen.dart';
import 'package:mera_ashiana/screens/drawer/widgets/drawer_header.dart';
import 'package:mera_ashiana/screens/blogs_screen.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/main.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // 🌐 URL launcher
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      // 🌙 FIXED DARK MODE BACKGROUND
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.white,

      child: Column(
        children: <Widget>[
          const CustomDrawerHeader(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: <Widget>[
                // 🏠 Home
                _buildMenuItem(
                  context,
                  loc.home,
                  Icons.home_outlined,
                  () => Navigator.pop(context),
                  isDark: isDark,
                ),

                // ❤️ Favorites (AUTH ONLY)
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
                          // silently ignore OR show snackbar if you want
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please login to access favorites"),
                            ),
                          );
                        }
                      },
                      isDark: isDark,
                    );
                  },
                ),

                // 📰 Blogs
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

                // ⚙️ Account Settings (ONLY if logged in)
                ValueListenableBuilder<bool>(
                  valueListenable: AuthState.isLoggedIn,
                  builder: (context, isLoggedIn, _) {
                    if (!isLoggedIn) {
                      return const SizedBox.shrink();
                    }

                    return _buildMenuItem(
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
                    );
                  },
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
                          if (value != null) {
                            appLocale.value = Locale(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                _buildDivider(isDark),

                // ❓ Help
                _buildMenuItem(
                  context,
                  loc.helpSupport,
                  Icons.help_outline_rounded,
                  () => _launchURL('https://mera-ashiana.com/contact'),
                  isDark: isDark,
                ),

                // ℹ️ About
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

          // 🚪 Logout (ONLY when logged in)
          ValueListenableBuilder<bool>(
            valueListenable: AuthState.isLoggedIn,
            builder: (context, isLoggedIn, _) {
              if (!isLoggedIn) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildMenuItem(
                  context,
                  loc.logout,
                  Icons.logout_rounded,
                  () {
                    Navigator.pop(context);
                    AuthHelper.showLogoutDialog(context);
                  },
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

  // ─────────────────────────────────────────────

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
