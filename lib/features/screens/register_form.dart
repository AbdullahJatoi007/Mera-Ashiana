import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/features/auth/auth_controller.dart';
import 'package:mera_ashiana/helpers/validation_helper.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
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

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

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
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _handleRegister() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    if (!terms) {
      AuthController.showError(
        context,
        "Please accept the Terms and Privacy Policy",
      );
      return;
    }

    AuthController.register(
      context,
      name.text.trim(),
      email.text.trim(),
      pass.text,
      confirm.text,
      agent,
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
            label: "Full Name",
            icon: Icons.person_outline,
            controller: name,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_emailFocus),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return "Full name is required";
              if (value.trim().length < 3)
                return "Name must be at least 3 characters";
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: "Email",
            icon: Icons.email_outlined,
            controller: email,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passFocus),
            validator: ValidationHelper.validateEmail,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: "Password",
            icon: Icons.lock_outline,
            controller: pass,
            focusNode: _passFocus,
            obscure: obscurePass,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_confirmFocus),
            toggle: () => setState(() => obscurePass = !obscurePass),
            validator: ValidationHelper.validatePassword,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: "Confirm Password",
            icon: Icons.lock_outline,
            controller: confirm,
            focusNode: _confirmFocus,
            obscure: obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
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
            onChanged: (v) => setState(() => terms = v!),
            label: "",
            isTerms: true,
            isDark: isDark,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _handleRegister,
              child: const Text(
                "REGISTER",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: widget.onSwitch,
            child: Text(
              "Already have an account? Sign In",
              style: TextStyle(
                color: isDark ? AppColors.accentYellow : AppColors.primaryNavy,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
