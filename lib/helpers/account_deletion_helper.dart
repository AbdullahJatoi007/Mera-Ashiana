import 'package:flutter/material.dart';

class AccountHelper {
  /// Displays a confirmation dialog before proceeding with account deletion.
  static void showDeleteAccountDialog(BuildContext context, {required VoidCallback onDeleteConfirmed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Delete Account"),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete your account? This action is permanent and all your data (saved properties, preferences) will be lost forever.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),

            // Confirm Delete Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                onDeleteConfirmed();    // Execute the deletion logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Optional: A helper for the actual API call logic
  static Future<void> performAccountDeletion() async {
    try {
      // 1. Call your Backend API here
      // await AuthService.deleteUserAccount();

      // 2. Clear local storage/cache
      // await LocalDB.clearAll();

      print("Account Deleted Successfully");
    } catch (e) {
      print("Error deleting account: $e");
    }
  }
}