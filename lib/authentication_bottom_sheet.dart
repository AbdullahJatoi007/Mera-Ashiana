import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/features/screens/login_form.dart';
import 'package:mera_ashiana/features/screens/register_form.dart';
import 'package:mera_ashiana/theme/app_colors.dart';

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 25),

            // Avatar icon
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primaryNavy.withOpacity(.05),
              child: Icon(
                isRegister ? Icons.person_add_rounded : Icons.person_rounded,
                color: AppColors.primaryNavy,
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
                      onSuccess: widget.onLoginSuccess,
                      onSwitch: () {
                        HapticFeedback.lightImpact();
                        setState(() => isRegister = false);
                      },
                    )
                  : LoginForm(
                      key: const ValueKey("login"),
                      onSuccess: widget.onLoginSuccess,
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
