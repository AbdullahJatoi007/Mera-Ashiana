import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/base/main_scaffold.dart%20%20';
import 'package:mera_ashiana/services/logout_service.dart';

class AuthHelper {
  static void showLogoutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    bool isLoggingOut = false;

    showDialog(
      context: context,
      barrierDismissible: !isLoggingOut, // Prevent closing while loading
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              loc.logout,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: isLoggingOut
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Logging out safely..."),
                    ],
                  )
                : const Text("Are you sure you want to log out?"),
            actions: isLoggingOut
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => isLoggingOut = true);

                        // 1. Perform Wipe
                        await LogoutService.logout();

                        if (!context.mounted) return;

                        // 2. Clear navigation stack and go to Home
                        // This ensures MainScaffold starts fresh with _selectedIndex = 0
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScaffold(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
          );
        },
      ),
    );
  }
}
