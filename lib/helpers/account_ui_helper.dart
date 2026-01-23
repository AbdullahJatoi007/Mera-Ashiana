import 'package:flutter/material.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import '../services/auth/account_deletion_service.dart';
import '../screens/base/main_scaffold.dart';

class AccountUIHelper {
  static void showDeleteConfirmation(BuildContext context) {
    bool isProcessing = false;
    bool hasConfirmed = false;

    // Use the theme defined in your AppTheme class
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: !isProcessing,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            // Automatically uses colorScheme.surface from your AppTheme
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Delete Account permanently?",
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error, // Uses errorRed from your theme
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "This will erase your profile, settings, and history. This action cannot be undone.",
                  style: theme
                      .textTheme
                      .bodyMedium, // Uses textGrey or textSecondary
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  title: Text(
                    "I understand that my data will be permanently deleted.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: hasConfirmed,
                  onChanged: isProcessing
                      ? null
                      : (val) => setState(() => hasConfirmed = val!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: colorScheme.error,
                  checkColor: colorScheme.onError,
                ),
                if (isProcessing) ...[
                  const SizedBox(height: 20),
                  CircularProgressIndicator(color: colorScheme.error),
                ],
              ],
            ),
            actions: isProcessing
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        elevation: 0,
                        disabledBackgroundColor: theme.disabledColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: hasConfirmed
                          ? () async {
                              setState(() => isProcessing = true);
                              try {
                                await AccountDeletionService.requestAccountDeletion();
                                if (!context.mounted) return;

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainScaffold(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                setState(() => isProcessing = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: colorScheme.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          : null,
                      child: const Text("Confirm Deletion"),
                    ),
                  ],
          );
        },
      ),
    );
  }
}
