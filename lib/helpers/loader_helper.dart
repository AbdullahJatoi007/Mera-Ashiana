import 'package:flutter/material.dart';

class LoaderHelper {
  // Private constructor for singleton
  LoaderHelper._();

  static final LoaderHelper instance = LoaderHelper._();

  bool _isShowing = false;

  // Show loading dialog
  void showLoader(BuildContext context, {String? message}) {
    if (_isShowing) return; // Prevent multiple dialogs
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return WillPopScope(
          onWillPop: () async => false, // Prevent back press
          child: Dialog(
            backgroundColor:
            isDark ? Colors.black87 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      message ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hide loading dialog
  void hideLoader(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}
