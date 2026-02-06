import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/google_login_service.dart';
import '../../services/auth_state.dart';
import '../../helpers/loader_helper.dart';
import '../../theme/app_colors.dart';

class AuthController {
  static Future<void> login(
    BuildContext context,
    String email,
    String password,
    VoidCallback onSuccess,
  ) async {
    await _performAuthAction(
      context,
      "Signing in...",
      () => AuthService.login(email: email, password: password),
      onSuccess,
      "Welcome Back!",
    );
  }

  static Future<void> register(
    BuildContext context,
    String name,
    String email,
    String password,
    String confirmPassword,
    bool isAgent,
    VoidCallback onSuccess,
  ) async {
    await _performAuthAction(
      context,
      "Creating account...",
      () => AuthService.register(
        username: name,
        email: email,
        password: password,
        repassword: confirmPassword,
        type: isAgent ? "agent" : "user",
      ),
      onSuccess,
      "Registration Successful!",
    );
  }

  static Future<void> google(
    BuildContext context,
    VoidCallback onSuccess,
    Function(bool) setLoading,
  ) async {
    HapticFeedback.lightImpact();
    setLoading(true);
    try {
      await GoogleLoginService.signInWithGoogle(captchaToken: '');
      AuthState.isLoggedIn.value = true;
      setLoading(false);
      onSuccess();
      showSuccess(context, "Successfully signed in with Google!");
      Navigator.pop(context);
    } catch (e) {
      setLoading(false);
      showError(
        context,
        e.toString().contains('cancelled')
            ? 'Sign in cancelled'
            : 'Google sign in failed.',
      );
    }
  }

  static Future<void> _performAuthAction(
    BuildContext context,
    String loadingMsg,
    Future Function() action,
    VoidCallback onSuccess,
    String successMsg,
  ) async {
    HapticFeedback.mediumImpact();
    LoaderHelper.instance.showLoader(context, message: loadingMsg);

    try {
      await action();
      LoaderHelper.instance.hideLoader(context);
      AuthState.isLoggedIn.value = true;
      onSuccess();
      Navigator.pop(context);
      showSuccess(context, successMsg);
    } on UnauthorizedException {
      LoaderHelper.instance.hideLoader(context);
      showError(context, "Invalid email or password");
    } on AuthException catch (e) {
      LoaderHelper.instance.hideLoader(context);
      showError(context, e.message);
    } catch (_) {
      LoaderHelper.instance.hideLoader(context);
      showError(context, "An unexpected error occurred.");
    }
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
