import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/google_login_service.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/services/auth_service.dart'; // Ensure this matches your file name

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
  // Existing Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // New Controllers for Registration
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isRegisterMode = false;

  // Checkbox States
  bool _isAgent = false;
  bool _termsAccepted = false;

  /// Combined handler for Login and Registration
  Future<void> _handleAuth() async {
    // 1. Validation for Registration
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
        // CALLING BACKEND: username, email, password, repassword, type
        await AuthService.register(
          username: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          repassword: _confirmPasswordController.text,
          type: _isAgent ? "agent" : "user",
        );
      } else {
        await LoginService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      // SUCCESS
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
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),

            CircleAvatar(
              radius: 35,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Icon(
                _isRegisterMode
                    ? Icons.person_add_rounded
                    : Icons.person_rounded,
                color: colorScheme.primary,
                size: 35,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _isRegisterMode ? "Create Account" : widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Fields
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
              const SizedBox(height: 16),
              _buildField(
                label: "Confirm Password",
                icon: Icons.lock_reset_outlined,
                controller: _confirmPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 10),

              // Agent Checkbox
              CheckboxListTile(
                value: _isAgent,
                onChanged: (val) => setState(() => _isAgent = val!),
                title: const Text(
                  "I'm an agent",
                  style: TextStyle(fontSize: 14),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: colorScheme.primary,
              ),

              // Terms Checkbox
              CheckboxListTile(
                value: _termsAccepted,
                onChanged: (val) => setState(() => _termsAccepted = val!),
                title: const Text(
                  "I have read and accept the Terms and Privacy Policy",
                  style: TextStyle(fontSize: 14),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: colorScheme.primary,
              ),
            ],

            const SizedBox(height: 25),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _handleAuth,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
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
                      : const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(0.2),
                    ),
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
                style: TextStyle(
                  color: colorScheme.primary,
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
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
    );
  }
}
