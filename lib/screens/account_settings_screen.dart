import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/edit_profile_screen.dart';
import 'package:mera_ashiana/main.dart'; // Ensure appThemeMode and appLocale are exported here

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Header
            _buildUserHeader(colorScheme),

            const SizedBox(height: 25),

            // 2. Preferences Group
            _buildSectionLabel(loc.general),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                title: loc.editProfile,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ),
              ),
              _buildLanguageTile(loc, colorScheme),
              _buildThemeTile(loc, colorScheme), // <--- Fixed Theme Toggle here
            ]),

            const SizedBox(height: 20),

            // 3. Notification Group
            _buildSectionLabel(loc.notifications),
            _buildSettingsGroup([_buildNotificationTile(loc, colorScheme)]),

            const SizedBox(height: 20),

            // 4. Security/Actions
            _buildSectionLabel(loc.accountActions),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.delete_forever_rounded,
                title: loc.deleteAccount,
                textColor: colorScheme.error,
                iconColor: colorScheme.error,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: tiles),
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

  Widget _buildUserHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.secondary,
            child: Icon(Icons.person, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zubair Ali',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'mrzubair@gmail.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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

  Widget _buildLanguageTile(AppLocalizations loc, ColorScheme colorScheme) {
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
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: colorScheme.onSurface,
              ),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(
                    loc.english,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                DropdownMenuItem(
                  value: 'ur',
                  child: Text(loc.urdu, style: const TextStyle(fontSize: 13)),
                ),
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

  // --- THE UPDATED THEME TILE ---
  // Replace your existing _buildThemeTile with this optimized version:
  Widget _buildThemeTile(AppLocalizations loc, ColorScheme colorScheme) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        // Calculate state once
        final bool isDarkValue = currentMode == ThemeMode.dark;

        return ListTile(
          leading: Icon(
            isDarkValue ? Icons.dark_mode : Icons.light_mode,
            color: colorScheme.secondary,
            size: 22,
          ),
          title: Text(
            loc.darkMode,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Switch.adaptive(
            value: isDarkValue,
            activeColor: colorScheme.secondary,
            onChanged: (bool value) {
              // Updating the notifier is now the only step.
              // Flutter's ValueListenableBuilder handles the rebuild efficiently.
              appThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(
    AppLocalizations loc,
    ColorScheme colorScheme,
  ) => ListTile(
    leading: Icon(
      Icons.notifications_active_outlined,
      color: colorScheme.primary,
    ),
    title: Text(
      loc.notifications,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    trailing: Switch.adaptive(
      value: _notificationsEnabled,
      activeColor: colorScheme.secondary,
      onChanged: (v) => setState(() => _notificationsEnabled = v),
    ),
  );
}
