import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/services/auth/auth_service.dart';
import 'package:mera_ashiana/data/services/google_login_service.dart';
import 'package:mera_ashiana/features/auth/auth_state.dart';
import 'package:mera_ashiana/features/auth/widgets/google_role_sheet.dart';
import 'package:mera_ashiana/shared/helpers/loader_helper.dart';

class AuthController {
  // --- OTP FLOW ---
  static Future<bool> requestOtp(
    BuildContext context,
    String name,
    String email,
    String phone,
    String password,
    bool isAgent,
  ) async {
    LoaderHelper.instance.showLoader(
      context,
      message: "Sending verification code...",
    );
    try {
      await AuthService.sendOtp(
        username: name,
        email: email,
        phone: phone,
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

  static Future<void> verifyAndRegister(
    BuildContext context,
    String email,
    String otp,
    VoidCallback onSuccess,
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
  static Future<void> login(
    BuildContext context,
    String email,
    String password,
    VoidCallback onSuccess,
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

  /// One Google button: try login with the Google ID token, and if no account
  /// exists yet, collect role + phone and finish registration on the same
  /// mobile endpoint.
  static Future<void> google(
    BuildContext context,
    VoidCallback onSuccess,
    Function(bool) setLoading,
  ) async {
    setLoading(true);

    try {
      debugPrint('🟢 [GOOGLE] button tapped — starting sign-in');

      final result = await GoogleLoginService.startGoogleSignIn();

      // Existing account → login success
      if (result.loggedIn) {
        debugPrint('✅ [GOOGLE] Existing account logged in.');
        AuthState.isLoggedIn.value = true;
        onSuccess();
        return;
      }

      // New Google account → complete registration
      if (result.needsRegistration) {
        debugPrint('📝 [GOOGLE] Registration required.');

        final reg = await showGoogleRoleSheet(
          context,
          email: result.email,
          name: result.name,
        );

        if (reg == null) {
          debugPrint('🟡 [GOOGLE] Registration cancelled by user.');
          return;
        }

        await GoogleLoginService.completeGoogleRegistration(
          idToken: result.idToken!,
          role: reg.$1, // 'user' | 'agency'
          phone: reg.$2,
        );

        debugPrint('✅ [GOOGLE] Registration completed.');

        AuthState.isLoggedIn.value = true;
        onSuccess();
        return;
      }

      debugPrint('🟡 [GOOGLE] Sign-in cancelled.');
    } catch (e, st) {
      debugPrint('❌ [GOOGLE] controller caught: $e');
      debugPrint('❌ [GOOGLE] $st');
      showError(context, e.toString());
    } finally {
      setLoading(false);
    }
  }

  // --- HELPERS ---
  static void showError(BuildContext context, String msg) {
    String cleanMsg = "Something went wrong. Please try again.";

    if (msg.contains("401") || msg.contains("bad response")) {
      cleanMsg = "Invalid email or password. Please try again.";
    } else if (msg.contains("SocketException") || msg.contains("connection")) {
      cleanMsg = "No internet connection. Check your network.";
    } else {
      cleanMsg = msg
          .replaceFirst('Exception: ', '')
          .replaceFirst('DioException: ', '')
          .replaceFirst('error: ', '')
          .trim();
    }

    if (cleanMsg.length > 80) {
      cleanMsg = "${cleanMsg.substring(0, 77)}...";
    }

    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) =>
          _FloatingSnackbar(message: cleanMsg, onDismiss: () => entry.remove()),
    );

    overlay.insert(entry);
  }
}

class _FloatingSnackbar extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _FloatingSnackbar({required this.message, required this.onDismiss});

  @override
  State<_FloatingSnackbar> createState() => _FloatingSnackbarState();
}

class _FloatingSnackbarState extends State<_FloatingSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    Future.delayed(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Positioned(
      bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 45,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}
