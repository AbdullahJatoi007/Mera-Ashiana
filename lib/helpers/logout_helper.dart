import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart';

class AuthHelper {
  /// Displays a professional logout confirmation dialog
  static void showLogoutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          loc.logout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(color: Colors.grey),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ),

          // Logout Button
          ElevatedButton(
            onPressed: () {
              // 1. Add any logic here to clear user session/token
              // e.g., SharedPreferences.clear();

              // 2. Navigate to Login and clear the navigation stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}