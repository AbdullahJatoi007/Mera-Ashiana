import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/account_ui_helper.dart';
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
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.accountSettings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFFFD54F) : colorScheme.primary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. General Preferences
            _buildSectionLabel(loc.general),
            _SettingsGroup(
              theme: theme,
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: loc.editProfile,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ),
                ),
                _LanguageTile(loc: loc),
                _ThemeTile(loc: loc),
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
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 3. Account Actions
            _buildSectionLabel(loc.accountActions),
            _SettingsGroup(
              theme: theme,
              children: [
                _SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  title: loc.deleteAccount,
                  textColor: colorScheme.error,
                  iconColor: colorScheme.error,
                  // Red for safety/policy compliance
                  onTap: () => AccountUIHelper.showDeleteConfirmation(context),
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

// --- Internal Helper Widgets ---

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
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color yellowAccent = const Color(0xFFFFD54F);

    return ListTile(
      leading: Icon(
        icon,
        color:
            iconColor ??
            (isDark ? yellowAccent : Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: isDark ? Colors.white30 : Colors.black26,
      ),
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return ListTile(
          leading: Icon(
            Icons.language_rounded,
            color: isDark
                ? const Color(0xFFFFD54F)
                : Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            loc.changeLanguage,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: DropdownButton<String>(
            value: locale.languageCode,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
            items: [
              DropdownMenuItem(value: 'en', child: Text(loc.english)),
              DropdownMenuItem(value: 'ur', child: Text(loc.urdu)),
            ],
            onChanged: (value) {
              if (value != null) appLocale.value = Locale(value);
            },
          ),
        );
      },
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        return ListTile(
          leading: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? const Color(0xFFFFD54F) : Colors.orangeAccent,
          ),
          title: Text(
            loc.darkMode,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Switch.adaptive(
            value: isDark,
            activeColor: const Color(0xFFFFD54F),
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
    required this.value,
    required this.onChanged,
  });

  final AppLocalizations loc;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        Icons.notifications_active_outlined,
        color: isDark
            ? const Color(0xFFFFD54F)
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        loc.notifications,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFFFFD54F),
        onChanged: onChanged,
      ),
    );
  }
}
