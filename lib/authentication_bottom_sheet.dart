import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/google_login_service.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/services/auth_service.dart'; // Ensure this matches your file name

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/google_login_service.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/services/auth_service.dart';

// Your defined color palette
class AppColors {
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF0A1D37);
  static const Color textGrey = Color(0xFF757575);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color errorRed = Color(0xFFD32F2F);
}

class AuthenticationBottomSheet extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final String title;

  const AuthenticationBottomSheet({
    super.key,
    required this.onLoginSuccess,
    this.title = "Sign In",
  });

  @override
  State<AuthenticationBottomSheet> createState() =>
      _AuthenticationBottomSheetState();
}

class _AuthenticationBottomSheetState extends State<AuthenticationBottomSheet> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isRegisterMode = false;
  bool _obscurePassword = true; // For eye toggle logic

  bool _isAgent = false;
  bool _termsAccepted = false;

  // --- Logic remains unchanged ---
  Future<void> _handleAuth() async {
    if (_isRegisterMode) {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        _showError("Please fill in all fields");
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError("Passwords do not match");
        return;
      }
      if (!_termsAccepted) {
        _showError("Please accept the Terms and Privacy Policy");
        return;
      }
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        await AuthService.register(
          username: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          repassword: _confirmPasswordController.text,
          type: _isAgent ? "agent" : "single_user",
        );
      } else {
        await LoginService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      AuthState.isLoggedIn.value = true;
      if (mounted) {
        widget.onLoginSuccess();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isRegisterMode ? "Registration Successful!" : "Welcome Back!",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      await GoogleLoginService.signInWithGoogle(captchaToken: '');
      AuthState.isLoggedIn.value = true;
      if (mounted) {
        widget.onLoginSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primaryNavy.withOpacity(0.05),
              child: Icon(
                _isRegisterMode
                    ? Icons.person_add_rounded
                    : Icons.person_rounded,
                color: AppColors.primaryNavy,
                size: 35,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isRegisterMode ? "Create Account" : widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 30),

            if (_isRegisterMode) ...[
              _buildField(
                label: "Full Name",
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
            ],

            _buildField(
              label: "Email",
              icon: Icons.email_outlined,
              controller: _emailController,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: "Password",
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
            ),

            if (_isRegisterMode) ...[
              const SizedBox(height: 10),
              Theme(
                data: ThemeData(unselectedWidgetColor: AppColors.textGrey),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _isAgent,
                      onChanged: (val) => setState(() => _isAgent = val!),
                      title: const Text(
                        "I'm an agent",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primaryNavy,
                      checkColor: AppColors.accentYellow,
                    ),
                    CheckboxListTile(
                      value: _termsAccepted,
                      onChanged: (val) => setState(() => _termsAccepted = val!),
                      title: const Text(
                        "Accept Terms & Privacy Policy",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primaryNavy,
                      checkColor: AppColors.accentYellow,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            // Main Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  foregroundColor: AppColors.primaryNavy, // High contrast
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _isLoading ? null : _handleAuth,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryNavy,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isRegisterMode ? "REGISTER" : "LOGIN",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            if (!_isRegisterMode) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                  icon: _isGoogleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.g_mobiledata,
                          size: 32,
                          color: AppColors.primaryNavy,
                        ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isRegisterMode = !_isRegisterMode);
              },
              child: Text(
                _isRegisterMode
                    ? "Already have an account? Sign In"
                    : "Don't have an account? Register Now",
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      cursorColor: AppColors.primaryNavy,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.primaryNavy),
        // Eye Toggle Implementation
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textGrey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Normal state border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        // Active/Focused state border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.accentYellow, width: 2),
        ),
      ),
    );
  }
}
