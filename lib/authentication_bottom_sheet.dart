import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/services/auth/auth_exceptions.dart';
import 'package:mera_ashiana/services/auth/auth_service.dart';
import 'package:mera_ashiana/services/google_login_service.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/helpers/validation_helper.dart';
import 'package:mera_ashiana/helpers/loader_helper.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:flutter/material.dart';


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
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus nodes for better UX
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // State
  bool _isGoogleLoading = false;
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isAgent = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate form using your ValidationHelper
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    if (_isRegisterMode && !_termsAccepted) {
      _showError("Please accept the Terms and Privacy Policy");
      return;
    }

    HapticFeedback.mediumImpact();

    // Show loader using your LoaderHelper
    LoaderHelper.instance.showLoader(
      context,
      message: _isRegisterMode ? 'Creating account...' : 'Signing in...',
    );

    try {
      if (_isRegisterMode) {
        await AuthService.register(
          username: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          repassword: _confirmPasswordController.text,
          type: _isAgent ? "agent" : "user",
        );
      } else {
        await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      // Hide loader
      if (mounted) LoaderHelper.instance.hideLoader(context);

      // Update auth state
      AuthState.isLoggedIn.value = true;

      if (mounted) {
        widget.onLoginSuccess();
        Navigator.pop(context);

        _showSuccess(
          _isRegisterMode
              ? "Registration Successful! Welcome aboard!"
              : "Welcome Back!",
        );
      }
    } on ValidationException catch (e) {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        _showError(e.message);
      }
    } on RateLimitException catch (e) {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        _showError(e.message);
      }
    } on NetworkException catch (e) {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        _showError(e.message);
      }
    } on UnauthorizedException catch (e) {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        _showError("Invalid email or password");
      }
    } on AuthException catch (e) {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        _showError("An unexpected error occurred. Please try again.");
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    HapticFeedback.lightImpact();
    setState(() => _isGoogleLoading = true);

    try {
      await GoogleLoginService.signInWithGoogle(captchaToken: '');
      AuthState.isLoggedIn.value = true;

      if (mounted) {
        setState(() => _isGoogleLoading = false);
        widget.onLoginSuccess();
        Navigator.pop(context);
        _showSuccess("Successfully signed in with Google!");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        _showError(
          e.toString().contains('cancelled')
              ? 'Sign in cancelled'
              : 'Google sign in failed. Please try again.',
        );
      }
    }
  }

  void _toggleMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      // Clear form when switching modes
      if (!_isRegisterMode) {
        _nameController.clear();
        _confirmPasswordController.clear();
        _isAgent = false;
        _termsAccepted = false;
      }
      // Reset form validation
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: _isRegisterMode ? 'Registration form' : 'Login form',
      child: Container(
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
        child: Form(
          key: _formKey,
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

                // Icon
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

                // Title
                Text(
                  _isRegisterMode ? "Create Account" : widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 30),

                // Registration: Name field
                if (_isRegisterMode) ...[
                  _buildTextField(
                    label: "Full Name",
                    icon: Icons.person_outline,
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    isDark: isDark,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                _buildTextField(
                  label: "Email",
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  isDark: isDark,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                  validator: ValidationHelper.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password field
                _buildTextField(
                  label: "Password",
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  isDark: isDark,
                  textInputAction: _isRegisterMode
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (_isRegisterMode) {
                      FocusScope.of(context)
                          .requestFocus(_confirmPasswordFocus);
                    } else {
                      _handleAuth();
                    }
                  },
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: ValidationHelper.validatePassword,
                ),

                // Registration: Confirm password
                if (_isRegisterMode) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Confirm Password",
                    icon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    isDark: isDark,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleAuth(),
                    onToggleVisibility: () {
                      setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (value) => ValidationHelper.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Agent checkbox
                  _buildCheckbox(
                    value: _isAgent,
                    onChanged: (val) => setState(() => _isAgent = val!),
                    label: "I'm a real estate agent",
                    isDark: isDark,
                  ),

                  // Terms checkbox
                  _buildCheckbox(
                    value: _termsAccepted,
                    onChanged: (val) => setState(() => _termsAccepted = val!),
                    label: "I accept the Terms & Privacy Policy",
                    isRequired: true,
                    isDark: isDark,
                  ),
                ],

                const SizedBox(height: 25),

                // Main action button
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
                    onPressed: _handleAuth,
                    child: Text(
                      _isRegisterMode ? "REGISTER" : "LOGIN",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Google sign-in (login only)
                if (!_isRegisterMode) ...[
                  const SizedBox(height: 20),

                  // Divider
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

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
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
                ],

                const SizedBox(height: 20),

                // Toggle mode button
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isRegisterMode
                        ? "Already have an account? Sign In"
                        : "Don't have an account? Register Now",
                    style: TextStyle(
                      color: isDark ? AppColors.accentYellow : AppColors.primaryNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isDark,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      textField: true,
      label: label,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        cursorColor: AppColors.primaryNavy,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textDark,
          fontSize: 15,
        ),
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white60 : AppColors.textGrey,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? AppColors.accentYellow : AppColors.primaryNavy,
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: isDark ? Colors.white60 : AppColors.textGrey,
              size: 20,
            ),
            onPressed: onToggleVisibility,
            tooltip: obscureText ? 'Show password' : 'Hide password',
          )
              : null,
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : AppColors.borderGrey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.accentYellow,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.errorRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.errorRed,
              width: 2,
            ),
          ),
          errorStyle: const TextStyle(
            fontSize: 12,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required void Function(bool?) onChanged,
    required String label,
    required bool isDark,
    bool isRequired = false,
  }) {
    return Semantics(
      checked: value,
      label: label,
      child: CheckboxListTile(
        value: value,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
        title: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
            if (isRequired)
              const Text(
                '*',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 16,
                ),
              ),
          ],
        ),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.primaryNavy,
        checkColor: AppColors.accentYellow,
        dense: true,
      ),
    );
  }
}