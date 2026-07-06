import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/features/auth/auth_controller.dart';
import 'package:mera_ashiana/shared/helpers/validation_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../widgets/auth_checkbox.dart';
import '../widgets/auth_text_field.dart';

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
  final phone = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  final otpController = TextEditingController();

  bool _showOtpField = false;
  bool _isLoading = false; // ⚡ Tracks active API operations
  bool agent = false;
  bool terms = false;
  bool obscurePass = true;
  bool obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to force a rebuild when text changes
    name.addListener(_onTextChanged);
    email.addListener(_onTextChanged);
    phone.addListener(_onTextChanged);
    pass.addListener(_onTextChanged);
    confirm.addListener(_onTextChanged);
    otpController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(
      () {},
    ); // Rebuilds the UI to instantly recalculate button enablement state
  }

  @override
  void dispose() {
    name.removeListener(_onTextChanged);
    email.removeListener(_onTextChanged);
    phone.removeListener(_onTextChanged);
    pass.removeListener(_onTextChanged);
    confirm.removeListener(_onTextChanged);
    otpController.removeListener(_onTextChanged);

    name.dispose();
    email.dispose();
    phone.dispose();
    pass.dispose();
    confirm.dispose();
    otpController.dispose();
    super.dispose();
  }

  // Determines if the form layout satisfies basic requirements to click send
  bool _isSubmitEnabled() {
    if (_isLoading) return false; // Always disable if an API call is running

    if (!_showOtpField) {
      return name.text.trim().isNotEmpty &&
          email.text.trim().isNotEmpty &&
          phone.text.trim().isNotEmpty &&
          pass.text.isNotEmpty &&
          confirm.text.isNotEmpty &&
          terms; // Button remains locked until terms are ticked
    } else {
      return otpController.text.trim().length == 6;
    }
  }

  void _handleAction() async {
    if (!_isSubmitEnabled()) return;

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 150));

    setState(() => _isLoading = true); // 🔒 Turn loading state on immediately

    try {
      if (!_showOtpField) {
        if (!_formKey.currentState!.validate()) {
          setState(() => _isLoading = false);
          return;
        }

        final success = await AuthController.requestOtp(
          context,
          name.text.trim(),
          email.text.trim(),
          phone.text.trim(),
          pass.text,
          agent,
        );
        if (success) setState(() => _showOtpField = true);
      } else {
        await AuthController.verifyAndRegister(
          context,
          email.text.trim(),
          otpController.text.trim(),
          widget.onSuccess,
        );
      }
    } finally {
      // Ensures loading turns back off even if the network fails or throws an exception
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Full name is required' : null,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: "Email",
          icon: Icons.email_outlined,
          controller: email,
          keyboardType: TextInputType.emailAddress,
          validator: ValidationHelper.validateEmail,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: "Phone Number",
          icon: Icons.phone_outlined,
          controller: phone,
          keyboardType: TextInputType.phone,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*')),
          ],
          validator: ValidationHelper.validatePhone,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: "Password",
          icon: Icons.lock_outline,
          controller: pass,
          obscure: obscurePass,
          toggle: () => setState(() => obscurePass = !obscurePass),
          validator: ValidationHelper.validatePassword,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: "Confirm Password",
          icon: Icons.lock_outline,
          controller: confirm,
          obscure: obscureConfirm,
          toggle: () => setState(() => obscureConfirm = !obscureConfirm),
          validator: (value) =>
              ValidationHelper.validateConfirmPassword(value, pass.text),
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
          onChanged: (v) => setState(() {
            terms = v!;
            _onTextChanged(); // Explicitly sync button state on checkbox tap
          }),
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
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 25),
        _buildSubmitButton("VERIFY & CREATE ACCOUNT", isDark),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() => _showOtpField = false),
          child: const Text(
            "Edit registration details",
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String text, bool isDark) {
    final enabled = _isSubmitEnabled();
    final buttonColor = isDark
        ? AppDarkColors.accentYellow
        : AppColors.accentYellow;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: AppColors.primaryNavy,
          disabledBackgroundColor: buttonColor.withOpacity(0.35),
          disabledForegroundColor: AppColors.primaryNavy.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: enabled ? _handleAction : null,
        // 🔒 Flutter automatically disables button when onPressed is null
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryNavy,
                  ),
                ),
              )
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSwitchButton(bool isDark) {
    return TextButton(
      onPressed: _isLoading ? null : widget.onSwitch,
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
