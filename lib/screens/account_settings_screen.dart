import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/screens/edit_profile_screen.dart';
import 'package:mera_ashiana/main.dart'; // Import to access appLocale

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.accountSettings),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 30),
            _buildSectionTitle(loc.general),
            _buildSettingsTile(
              icon: Icons.person_outline,
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
            const Divider(height: 40, color: AppColors.borderGrey),
            _buildSectionTitle(loc.notifications),
            _buildNotificationTile(loc),
            const Divider(height: 40, color: AppColors.borderGrey),
            _buildSectionTitle(loc.accountActions),
            _buildSettingsTile(
              icon: Icons.delete_forever_outlined,
              title: loc.deleteAccount,
              textColor: AppColors.errorRed,
              iconColor: AppColors.errorRed,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(AppLocalizations loc) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.language, color: AppColors.primaryNavy),
      title: Text(loc.changeLanguage),
      trailing: DropdownButton<String>(
        value: appLocale.value.languageCode, // Listen to global locale
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(value: 'en', child: Text(loc.english)),
          DropdownMenuItem(value: 'ur', child: Text(loc.urdu)),
        ],
        onChanged: (value) {
          if (value != null) appLocale.value = Locale(value); // Update Global
        },
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.accentYellow,
            child: Icon(Icons.person, color: AppColors.primaryNavy),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zubair Ali',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'mrzubair@gmail.com',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 10),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textGrey,
      ),
    ),
  );

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.primaryNavy),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildThemeTile(AppLocalizations loc) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
      color: AppColors.accentYellow,
    ),
    title: Text(loc.darkMode),
    trailing: Switch(
      value: _isDarkMode,
      activeColor: AppColors.accentYellow,
      onChanged: (v) => setState(() => _isDarkMode = v),
    ),
  );

  Widget _buildNotificationTile(AppLocalizations loc) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.notifications_none, color: AppColors.primaryNavy),
    title: Text(loc.notifications),
    trailing: Switch(
      value: _notificationsEnabled,
      activeColor: AppColors.accentYellow,
      onChanged: (v) => setState(() => _notificationsEnabled = v),
    ),
  );
}
