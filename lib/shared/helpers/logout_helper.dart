import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/data/services/logout_service.dart';
import 'package:mera_ashiana/features/auth/auth_state.dart';

import '../widgets/base/main_scaffold.dart';

class AuthHelper {
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Clean up physical data
              await LogoutService.logout();

              // 2. Update UI notifier (Magic line)
              AuthState.isLoggedIn.value = false;

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                // 3. Reset app to clean state
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScaffold()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
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
