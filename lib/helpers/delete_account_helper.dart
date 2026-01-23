import 'package:flutter/material.dart';
import '../services/auth/account_service.dart';
import '../screens/base/main_scaffold.dart';

class DeleteAccountHelper {
  static void confirmDeletion(BuildContext context) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Confirm Account Deletion"),
            content: isLoading
                ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.red),
                SizedBox(height: 15),
                Text("Processing request..."),
              ],
            )
                : const Text("Are you sure? This will permanently remove all your data. This action cannot be undone."),
            actions: isLoading ? [] : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Keep Account"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  setState(() => isLoading = true);

                  try {
                    await AccountService.deleteUserAccount();

                    if (!context.mounted) return;

                    // Exit to home and clear all screens
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScaffold()),
                          (route) => false,
                    );
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text("Delete Everything"),
              ),
            ],
          );
        },
      ),
    );
  }
}