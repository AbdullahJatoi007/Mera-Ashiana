import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/features/auth/auth_state.dart';
import 'package:mera_ashiana/data/services/logout_service.dart';

class AuthHelper {
  static void showLogoutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    bool isLoggingOut = false;

    showDialog(
      context: context,
      // Prevents closing the dialog by tapping outside once the process starts
      barrierDismissible: !isLoggingOut,
      builder: (dialogContext) => StatefulBuilder(
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
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Logging out safely..."),
                      // Consider adding this to l10n
                    ],
                  )
                : const Text(
                    "Are you sure you want to log out of your account?",
                  ),
            actions: isLoggingOut
                ? [] // Hide buttons during the async process
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => isLoggingOut = true);

                        try {
                          // 1. Perform the heavy lifting (clearing prefs, cache, etc.)
                          await LogoutService.logout();

                          // 2. Update global state
                          // This should naturally trigger your UI to redirect
                          AuthState.isLoggedIn.value = false;
                        } catch (e) {
                          // Optional: Handle errors (e.g., show a Toast)
                        } finally {
                          // 3. Dismiss dialog safely
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
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
