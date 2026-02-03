import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/features/auth/auth_controller.dart';
import 'package:mera_ashiana/helpers/validation_helper.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import '../widgets/auth_text_field.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onSuccess;

  const LoginForm({super.key, required this.onSwitch, required this.onSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Focus Nodes
  final _passwordFocus = FocusNode();

  // State
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    AuthController.login(
      context,
      emailController.text.trim(),
      passwordController.text,
      widget.onSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          AuthTextField(
            label: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
            validator: ValidationHelper.validateEmail,
          ),

          const SizedBox(height: 16),

          // Password Field
          AuthTextField(
            label: "Password",
            icon: Icons.lock_outline,
            controller: passwordController,
            focusNode: _passwordFocus,
            obscure: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            toggle: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: ValidationHelper.validatePassword,
          ),

          const SizedBox(height: 25),

          // Main Login Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.primaryNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _handleLogin,
              child: const Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // OR Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? Colors.white24 : AppColors.borderGrey,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: isDark ? Colors.white60 : AppColors.textGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? Colors.white24 : AppColors.borderGrey,
                  thickness: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Google Login Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: _isGoogleLoading
                  ? null
                  : () => AuthController.google(
                      context,
                      widget.onSuccess,
                      (loading) => setState(() => _isGoogleLoading = loading),
                    ),
              icon: _isGoogleLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : const Icon(
                      Icons.g_mobiledata,
                      size: 32,
                      color: AppColors.primaryNavy,
                    ),
              label: Text(
                "Continue with Google",
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.white24 : AppColors.borderGrey,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Switch to Register Mode Button
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onSwitch();
            },
            child: Text(
              "Don't have an account? Register Now",
              style: TextStyle(
                color: isDark ? AppColors.accentYellow : AppColors.primaryNavy,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
