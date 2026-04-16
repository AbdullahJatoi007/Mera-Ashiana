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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

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
          AuthTextField(
            label: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
            validator: ValidationHelper.validateEmail,
          ),
          const SizedBox(height: 16),
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
          _buildButton(
            label: "LOGIN",
            onPressed: _handleLogin,
            color: AppColors.accentYellow,
            textColor: AppColors.primaryNavy,
          ),
          const SizedBox(height: 20),
          _buildDivider(isDark),
          const SizedBox(height: 20),
          _buildGoogleButton(isDark),
          const SizedBox(height: 20),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onPressed, required Color color, required Color textColor}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    final color = isDark ? Colors.white24 : AppColors.borderGrey;
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("OR", style: TextStyle(color: isDark ? Colors.white60 : AppColors.textGrey, fontSize: 12)),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }

  Widget _buildGoogleButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: _isGoogleLoading ? null : () => AuthController.google(context, widget.onSuccess, (l) => setState(() => _isGoogleLoading = l)),
        icon: _isGoogleLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.g_mobiledata, size: 32),
        label: const Text("Continue with Google"),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: BorderSide(color: isDark ? Colors.white24 : AppColors.borderGrey),
        ),
      ),
    );
  }
}