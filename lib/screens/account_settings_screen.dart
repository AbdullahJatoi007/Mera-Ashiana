import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/screens/edit_profile_screen.dart';
import 'package:mera_ashiana/main.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  // Specific brand colors
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly softer background
      appBar: AppBar(
        title: Text(
          loc.accountSettings,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryNavy,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Quick View
            _buildUserHeader(),

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
              _buildLanguageTile(loc),
              _buildThemeTile(loc),
            ]),

            const SizedBox(height: 20),

            // 3. Notification Group
            _buildSectionLabel(loc.notifications),
            _buildSettingsGroup([_buildNotificationTile(loc)]),

            const SizedBox(height: 20),

            // 4. Security/Actions
            _buildSectionLabel(loc.accountActions),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.delete_forever_rounded,
                title: loc.deleteAccount,
                textColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper to group tiles inside a card
  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: accentYellow,
            child: Icon(Icons.person, color: primaryNavy),
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
    return ListTile(
      leading: Icon(icon, color: iconColor ?? primaryNavy, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? primaryNavy,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile(AppLocalizations loc) {
    return ListTile(
      leading: const Icon(Icons.language_rounded, color: primaryNavy, size: 22),
      title: Text(
        loc.changeLanguage,
        style: const TextStyle(
          color: primaryNavy,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          value: appLocale.value.languageCode,
          underline: const SizedBox(),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: primaryNavy,
          ),
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(loc.english, style: const TextStyle(fontSize: 13)),
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
  }

  Widget _buildThemeTile(AppLocalizations loc) => ListTile(
    leading: Icon(
      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
      color: accentYellow,
      size: 22,
    ),
    title: Text(
      loc.darkMode,
      style: const TextStyle(
        color: primaryNavy,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    trailing: Switch.adaptive(
      value: _isDarkMode,
      activeColor: accentYellow,
      onChanged: (v) => setState(() => _isDarkMode = v),
    ),
  );

  Widget _buildNotificationTile(AppLocalizations loc) => ListTile(
    leading: const Icon(
      Icons.notifications_active_outlined,
      color: primaryNavy,
      size: 22,
    ),
    title: Text(
      loc.notifications,
      style: const TextStyle(
        color: primaryNavy,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    trailing: Switch.adaptive(
      value: _notificationsEnabled,
      activeColor: accentYellow,
      onChanged: (v) => setState(() => _notificationsEnabled = v),
    ),
  );
}
