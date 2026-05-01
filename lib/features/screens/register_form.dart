import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/features/auth/auth_controller.dart';
import 'package:mera_ashiana/helpers/validation_helper.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import '../../theme/app_colors_dark.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_checkbox.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onSuccess;

  const RegisterForm({
    super.key,
    required this.onSwitch,
    required this.onSuccess,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  final otpController = TextEditingController();

  bool _showOtpField = false;
  bool agent = false;
  bool terms = false;
  bool obscurePass = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    confirm.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _handleAction() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 150));

    if (!_showOtpField) {
      if (!_formKey.currentState!.validate()) return;
      if (!terms) {
        AuthController.showError(
          context,
          "Please accept the Terms & Privacy Policy",
        );
        return;
      }

      final success = await AuthController.requestOtp(
        context,
        name.text.trim(),
        email.text.trim(),
        pass.text,
        agent,
      );
      if (success) setState(() => _showOtpField = true);
    } else {
      if (otpController.text.length < 6) {
        AuthController.showError(context, "Please enter the 6-digit code");
        return;
      }
      await AuthController.verifyAndRegister(
        context,
        email.text.trim(),
        otpController.text.trim(),
        widget.onSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showOtpField
            ? _buildOtpView(isDark)
            : _buildRegisterView(isDark),
      ),
    );
  }

  Widget _buildRegisterView(bool isDark) {
    return Column(
      key: const ValueKey("reg_view"),
      children: [
        AuthTextField(
          label: "Full Name",
          icon: Icons.person_outline,
          controller: name,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: "Email",
          icon: Icons.email_outlined,
          controller: email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: "Password",
          icon: Icons.lock_outline,
          controller: pass,
          obscure: obscurePass,
          toggle: () => setState(() => obscurePass = !obscurePass),
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: "Confirm Password",
          icon: Icons.lock_outline,
          controller: confirm,
          obscure: obscureConfirm,
          toggle: () => setState(() => obscureConfirm = !obscureConfirm),
        ),
        const SizedBox(height: 10),
        AuthCheckbox(
          value: agent,
          onChanged: (v) => setState(() => agent = v!),
          label: "I'm a real estate agent",
          isDark: isDark,
        ),
        AuthCheckbox(
          value: terms,
          onChanged: (v) => setState(() => terms = v!),
          label: "",
          isTerms: true,
          isDark: isDark,
        ),
        const SizedBox(height: 25),
        _buildSubmitButton("SEND VERIFICATION CODE", isDark),
        _buildSwitchButton(isDark),
      ],
    );
  }

  Widget _buildOtpView(bool isDark) {
    return Column(
      key: const ValueKey("otp_view"),
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 60,
          color: isDark ? AppDarkColors.accentYellow : AppColors.accentYellow,
        ),
        const SizedBox(height: 16),
        Text(
          "Verify Your Email",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We sent a code to ${email.text}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: "6-Digit Code",
          icon: Icons.vpn_key_outlined,
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 25),
        _buildSubmitButton("VERIFY & CREATE ACCOUNT", isDark),
        TextButton(
          onPressed: () => setState(() => _showOtpField = false),
          child: const Text(
            "Edit registration details",
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String text, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppDarkColors.accentYellow
              : AppColors.accentYellow,
          foregroundColor: AppColors.primaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _handleAction,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSwitchButton(bool isDark) {
    return TextButton(
      onPressed: widget.onSwitch,
      child: Text(
        "Already have an account? Sign In",
        style: TextStyle(
          color: isDark ? AppDarkColors.accentYellow : AppColors.primaryNavy,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
