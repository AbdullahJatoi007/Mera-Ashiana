import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import 'package:mera_ashiana/core/theme/app_colors_dark.dart';
import '../../data/services/profile_service.dart';

class EmailVerificationDialog extends StatefulWidget {
  final String newEmail;

  const EmailVerificationDialog({super.key, required this.newEmail});

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    // Detect Theme Context
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Select Colors based on your provided scheme
    final Color yellow = isDark
        ? AppDarkColors.accentYellow
        : AppColors.accentYellow;
    final Color navy = isDark
        ? AppDarkColors.primaryNavy
        : AppColors.primaryNavy;
    final Color surface = isDark ? AppDarkColors.surface : AppColors.white;
    final Color textColor = isDark
        ? AppDarkColors.textPrimary
        : AppColors.textDark;
    final Color secondaryText = isDark
        ? AppDarkColors.textSecondary
        : AppColors.textGrey;
    final Color borderColor = isDark
        ? AppDarkColors.borderGrey
        : AppColors.borderGrey;

    return AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Verify New Email",
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "We sent a 6-digit code to:",
            style: TextStyle(color: secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            widget.newEmail,
            style: TextStyle(
              color: yellow,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: TextStyle(color: textColor),
            cursorColor: yellow,
            decoration: InputDecoration(
              labelText: "Enter OTP",
              labelStyle: TextStyle(color: secondaryText),
              counterStyle: TextStyle(color: secondaryText),
              prefixIcon: Icon(Icons.vpn_key_outlined, color: yellow, size: 20),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade50,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: yellow, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: secondaryText)),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verify,
          style: ElevatedButton.styleFrom(
            backgroundColor: yellow,
            foregroundColor: navy,
            // Text color on top of yellow
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isVerifying
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    // Progress indicator matches the Navy text color for contrast
                    valueColor: AlwaysStoppedAnimation<Color>(navy),
                  ),
                )
              : const Text(
                  "Verify & Save",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the full 6-digit code"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final success = await ProfileService.verifyEmailChange(otp);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Invalid or expired OTP"),
              backgroundColor: isDarkTheme(context)
                  ? AppDarkColors.errorRed
                  : AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred during verification"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  bool isDarkTheme(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
