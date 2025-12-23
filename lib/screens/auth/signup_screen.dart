import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/loader_helper.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart';
import 'package:mera_ashiana/base_screens/home_screen.dart';
import 'package:mera_ashiana/services/auth_service.dart';
import 'package:mera_ashiana/theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _acceptedTerms = false;
  int _selectedRoleIndex = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------- NORMAL SIGNUP ----------------
  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) return;

    LoaderHelper.instance.showLoader(context, message: "Registering...");

    try {
      final result = await AuthService.register(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        repassword: _confirmPasswordController.text.trim(),
        type: _selectedRoleIndex == 0 ? "user" : "agent",
      );

      LoaderHelper.instance.hideLoader(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registered successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      LoaderHelper.instance.hideLoader(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join Ashiana to find your perfect home',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                ),
                const SizedBox(height: 24),
                _buildRoleSelector(),
                const SizedBox(height: 24),
                _buildTextField(
                  _nameController,
                  'Full Name',
                  Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  'Email Address',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _passwordController,
                  'Password',
                  Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _confirmPasswordController,
                  'Confirm Password',
                  Icons.lock_reset_outlined,
                  isPassword: true,
                  isConfirmField: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (val) => setState(() => _acceptedTerms = val!),
                      activeColor: AppColors.primaryNavy,
                      checkColor: AppColors.accentYellow,
                    ),
                    const Expanded(
                      child: Text('I accept terms & privacy policy'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedRoleIndex == 0
                        ? 'REGISTER AS USER'
                        : 'REGISTER AS AGENT',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ToggleButtons(
            isSelected: [_selectedRoleIndex == 0, _selectedRoleIndex == 1],
            onPressed: (index) => setState(() => _selectedRoleIndex = index),
            borderRadius: BorderRadius.circular(8),
            selectedColor: AppColors.primaryNavy,
            fillColor: AppColors.accentYellow,
            color: AppColors.textGrey,
            renderBorder: false,
            constraints: BoxConstraints.expand(
              width: (constraints.maxWidth / 2) - 4,
              height: 48,
            ),
            children: const [
              Text('User', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Agent', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isConfirmField = false,
    TextInputType? keyboardType,
  }) {
    bool obscure = isPassword
        ? (isConfirmField ? _isConfirmObscured : _isObscured)
        : false;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) return '$label is required';
        if (label.contains('Email') && !value.contains('@'))
          return 'Invalid email';
        if (label.contains('Password') && value.length < 6)
          return 'Min 6 characters';
        if (isConfirmField && value != _passwordController.text)
          return 'Passwords do not match';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primaryNavy),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primaryNavy,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirmField) {
                      _isConfirmObscured = !_isConfirmObscured;
                    } else {
                      _isObscured = !_isObscured;
                    }
                  });
                },
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentYellow, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
