import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import 'package:mera_ashiana/core/theme/app_colors_dark.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/screens/login_form.dart';
import 'features/auth/screens/register_form.dart';

class AuthenticationBottomSheet extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthenticationBottomSheet({super.key, required this.onLoginSuccess});

  @override
  State<AuthenticationBottomSheet> createState() =>
      _AuthenticationBottomSheetState();
}

class _AuthenticationBottomSheetState extends State<AuthenticationBottomSheet> {
  bool isRegister = false;

  /// Handles the successful login/registration event
  void _handleAuthSuccess() {
    // 1. Close the bottom sheet
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // 2. Execute the callback to refresh the calling screen (Home or Profile)
    widget.onLoginSuccess();

    // Optional: Provide haptic feedback for success
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color iconColor = isDark
        ? AppDarkColors.accentYellow
        : AppColors.primaryNavy;
    final Color iconBgColor = isDark
        ? AppDarkColors.accentYellow.withOpacity(0.15)
        : AppColors.primaryNavy.withOpacity(0.05);
    final Color handleColor = isDark ? Colors.white24 : AppColors.borderGrey;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),

            CircleAvatar(
              radius: 35,
              backgroundColor: iconBgColor,
              child: Icon(
                isRegister ? Icons.person_add_rounded : Icons.person_rounded,
                color: iconColor,
                size: 35,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isRegister ? "Create Account" : "Sign In",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),

            const SizedBox(height: 30),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isRegister
                  ? RegisterForm(
                      key: const ValueKey("register"),
                      onSuccess: _handleAuthSuccess,
                      onSwitch: () {
                        HapticFeedback.lightImpact();
                        setState(() => isRegister = false);
                      },
                    )
                  : LoginForm(
                      key: const ValueKey("login"),
                      onSuccess: _handleAuthSuccess,
                      onSwitch: () {
                        HapticFeedback.lightImpact();
                        setState(() => isRegister = true);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
