import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/features/screens/login_form.dart';
import 'package:mera_ashiana/features/screens/register_form.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';

class AuthenticationBottomSheet extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthenticationBottomSheet({super.key, required this.onLoginSuccess});

  @override
  State<AuthenticationBottomSheet> createState() =>
      _AuthenticationBottomSheetState();
}

class _AuthenticationBottomSheetState extends State<AuthenticationBottomSheet> {
  bool isRegister = false;

  @override
  Widget build(BuildContext context) {
    // 1. Get the keyboard height
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
      // 2. We use 'padding' carefully.
      // Including bottomInset here ensures the whole UI moves up when the keyboard opens.
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
        // 3. This allows the sheet to grow if the form is long
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      onSuccess: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        widget.onLoginSuccess();
                      },
                      onSwitch: () {
                        HapticFeedback.lightImpact();
                        setState(() => isRegister = false);
                      },
                    )
                  : LoginForm(
                      key: const ValueKey("login"),
                      onSuccess: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        widget.onLoginSuccess();
                      },
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
