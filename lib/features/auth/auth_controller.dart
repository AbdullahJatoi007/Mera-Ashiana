import 'package:flutter/material.dart';
import 'package:mera_ashiana/services/auth/auth_service.dart';
import 'package:mera_ashiana/services/google_login_service.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/helpers/loader_helper.dart';

class AuthController {

  // --- OTP FLOW ---

  /// Step 1: Send OTP to the user's email
  static Future<bool> requestOtp(
      BuildContext context,
      String name,
      String email,
      String password,
      bool isAgent
      ) async {
    LoaderHelper.instance.showLoader(context, message: "Sending verification code...");
    try {
      await AuthService.sendOtp(
        username: name,
        email: email,
        password: password,
        type: isAgent ? "agency" : "user",
      );
      LoaderHelper.instance.hideLoader(context);
      return true;
    } catch (e) {
      LoaderHelper.instance.hideLoader(context);
      showError(context, e.toString());
      return false;
    }
  }

  /// Step 2: Verify OTP and finalize registration
  static Future<void> verifyAndRegister(
      BuildContext context,
      String email,
      String otp,
      VoidCallback onSuccess
      ) async {
    LoaderHelper.instance.showLoader(context, message: "Verifying...");
    try {
      await AuthService.verifyOtpAndRegister(email: email, otp: otp);
      LoaderHelper.instance.hideLoader(context);
      AuthState.isLoggedIn.value = true;
      onSuccess();
    } catch (e) {
      LoaderHelper.instance.hideLoader(context);
      showError(context, e.toString());
    }
  }

  // --- LOGIN METHODS ---

  /// Standard Email/Password Login
  static Future<void> login(
      BuildContext context,
      String email,
      String password,
      VoidCallback onSuccess
      ) async {
    LoaderHelper.instance.showLoader(context, message: "Logging in...");
    try {
      await AuthService.login(email: email, password: password);
      LoaderHelper.instance.hideLoader(context);
      AuthState.isLoggedIn.value = true;
      onSuccess();
    } catch (e) {
      LoaderHelper.instance.hideLoader(context);
      showError(context, e.toString());
    }
  }

  /// Google Authentication Login
  static Future<void> google(
      BuildContext context,
      VoidCallback onSuccess,
      Function(bool) setLoading
      ) async {
    setLoading(true);
    try {
      await GoogleLoginService.signInWithGoogle();
      AuthState.isLoggedIn.value = true;
      onSuccess();
    } catch (e) {
      showError(context, e.toString());
    } finally {
      setLoading(false);
    }
  }

  // --- HELPERS ---

  /// Static Error Helper for displaying SnackBars
  static void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}