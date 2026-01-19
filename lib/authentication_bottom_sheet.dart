import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/services/login_service.dart';
import 'package:mera_ashiana/services/google_login_service.dart';
import 'package:mera_ashiana/services/auth_state.dart'; // Ensure AuthState is imported

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

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isRegisterMode = false; // Toggles between Login and Register UI

  /// Combined handler for Login and Registration
  Future<void> _handleAuth() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        // TODO: Call your Registration Service here
        // await RegisterService.register(email: ..., password: ...);
      } else {
        await LoginService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      // SUCCESS: Update global state and notify listeners (like ProfileScreen)
      AuthState.isLoggedIn.value = true;

      if (mounted) {
        widget.onLoginSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      await GoogleLoginService.signInWithGoogle(captchaToken: '');

      // SUCCESS: Update global state
      AuthState.isLoggedIn.value = true;

      if (mounted) {
        widget.onLoginSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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

            // Icon
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

            // Dynamic Title
            Text(
              _isRegisterMode ? "Create Account" : widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isRegisterMode
                  ? "Join us to find your perfect home."
                  : "Sign in to access full features.",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 30),

            // Fields
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
            const SizedBox(height: 25),

            // Primary Action Button
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
              // Google Login (Only show in Login Mode)
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

            // Toggle Login/Register
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isRegisterMode = !_isRegisterMode);
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  children: [
                    TextSpan(
                      text: _isRegisterMode
                          ? "Already have an account? "
                          : "Don't have an account? ",
                    ),
                    TextSpan(
                      text: _isRegisterMode ? "Sign In" : "Register Now",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
