import 'package:flutter/material.dart';
import '../../data/services/auth/account_deletion_service.dart';

class AccountHelper {
  /// Shows confirmation dialog before deleting account
  static void showDeleteAccountDialog(
    BuildContext context, {
    required VoidCallback onDeleteConfirmed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Delete Account"),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete your account? "
            "This action is permanent and all your data will be lost forever.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDeleteConfirmed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("DELETE"),
            ),
          ],
        );
      },
    );
  }

  /// Optional helper (can be used if needed)
  static Future<void> performAccountDeletion() async {
    await AccountDeletionService.requestAccountDeletion();
  }
}
