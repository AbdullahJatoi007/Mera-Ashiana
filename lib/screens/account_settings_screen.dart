import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/account_deletion_helper.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/edit_profile_screen.dart';
import 'package:mera_ashiana/main.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.accountSettings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Preferences Group
            _buildSectionLabel(loc.general),
            _SettingsGroup(
              theme: theme,
              children: [
                _SettingsTile(
                  colorScheme: colorScheme,
                  icon: Icons.person_outline_rounded,
                  title: loc.editProfile,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ),
                ),
                _LanguageTile(loc: loc, colorScheme: colorScheme),
                _ThemeTile(loc: loc, colorScheme: colorScheme),
              ],
            ),

            const SizedBox(height: 25),

            // 2. Notification Group
            _buildSectionLabel(loc.notifications),
            _SettingsGroup(
              theme: theme,
              children: [
                _NotificationTile(
                  loc: loc,
                  colorScheme: colorScheme,
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 3. Security/Actions
            _buildSectionLabel(loc.accountActions),
            _SettingsGroup(
              theme: theme,
              children: [
                _SettingsTile(
                  colorScheme: colorScheme,
                  icon: Icons.delete_forever_rounded,
                  title: loc.deleteAccount,
                  textColor: colorScheme.error,
                  iconColor: colorScheme.error,
                  onTap: () {
                    AccountHelper.showDeleteAccountDialog(
                      context,
                      onDeleteConfirmed: () {
                        AccountHelper.performAccountDeletion();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 8),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.1,
      ),
    ),
  );
}

// --- Internal Helper Widgets (Keep these as they were) ---

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.theme, required this.children});

  final ThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.colorScheme,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final ColorScheme colorScheme;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: colorScheme.onSurface.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.loc, required this.colorScheme});

  final AppLocalizations loc;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return ListTile(
          leading: Icon(Icons.language_rounded, color: colorScheme.primary),
          title: Text(
            loc.changeLanguage,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: locale.languageCode,
              underline: const SizedBox(),
              dropdownColor: colorScheme.surface,
              icon: Icon(Icons.keyboard_arrow_down, size: 18),
              items: [
                DropdownMenuItem(value: 'en', child: Text(loc.english)),
                DropdownMenuItem(value: 'ur', child: Text(loc.urdu)),
              ],
              onChanged: (value) {
                if (value != null) appLocale.value = Locale(value);
              },
            ),
          ),
        );
      },
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.loc, required this.colorScheme});

  final AppLocalizations loc;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        return ListTile(
          leading: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: colorScheme.secondary,
          ),
          title: Text(
            loc.darkMode,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: Switch.adaptive(
            value: isDark,
            activeColor: colorScheme.secondary,
            onChanged: (v) =>
                appThemeMode.value = v ? ThemeMode.dark : ThemeMode.light,
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.loc,
    required this.colorScheme,
    required this.value,
    required this.onChanged,
  });

  final AppLocalizations loc;
  final ColorScheme colorScheme;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.notifications_active_outlined,
        color: colorScheme.primary,
      ),
      title: Text(
        loc.notifications,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: colorScheme.secondary,
        onChanged: onChanged,
      ),
    );
  }
}
