import 'package:flutter/material.dart';
import 'package:mera_ashiana/helpers/loader_helper.dart';
import 'package:mera_ashiana/helpers/validation_helper.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart';
import 'package:mera_ashiana/base_screens/home_screen.dart';
import 'package:mera_ashiana/services/auth_service.dart';

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

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms & privacy policy'),
        ),
      );
      return;
    }

    LoaderHelper.instance.showLoader(context, message: "Registering...");

    try {
      final result = await AuthService.register(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        repassword: _confirmPasswordController.text.trim(),
        type: _selectedRoleIndex == 0 ? "user" : "agent",
      );

      if (!mounted) return;
      LoaderHelper.instance.hideLoader(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registered successfully!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      LoaderHelper.instance.hideLoader(context);
      final errorMessage = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Ashiana to find your perfect home',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                _buildRoleSelector(theme),
                const SizedBox(height: 24),
                _buildTextField(
                  theme,
                  _nameController,
                  'Full Name',
                  Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  theme,
                  _emailController,
                  'Email Address',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isEmail: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  theme,
                  _passwordController,
                  'Password',
                  Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  theme,
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
                      activeColor: colorScheme.primary,
                      checkColor: colorScheme.secondary,
                    ),
                    Expanded(
                      child: Text(
                        'I accept terms & privacy policy',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: colorScheme.primary,
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

  Widget _buildRoleSelector(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ToggleButtons(
            isSelected: [_selectedRoleIndex == 0, _selectedRoleIndex == 1],
            onPressed: (index) => setState(() => _selectedRoleIndex = index),
            borderRadius: BorderRadius.circular(8),
            selectedColor: theme.colorScheme.onSecondary,
            fillColor: theme.colorScheme.secondary,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
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
    ThemeData theme,
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isConfirmField = false,
    bool isEmail = false,
    TextInputType? keyboardType,
  }) {
    final cs = theme.colorScheme;
    bool obscure = isPassword
        ? (isConfirmField ? _isConfirmObscured : _isObscured)
        : false;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: cs.onSurface.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: cs.primary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: cs.primary,
                ),
                onPressed: () => setState(() {
                  if (isConfirmField)
                    _isConfirmObscured = !_isConfirmObscured;
                  else
                    _isObscured = !_isObscured;
                }),
              )
            : null,
        filled: true,
        fillColor: cs.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.secondary, width: 2),
        ),
      ),
      validator: (val) {
        // --- CALLING HELPER CLASS ---
        if (isEmail) return ValidationHelper.validateEmail(val);

        if (isPassword) {
          if (isConfirmField) {
            return ValidationHelper.validateConfirmPassword(
              val,
              _passwordController.text,
            );
          }
          return ValidationHelper.validatePassword(val);
        }

        if (val == null || val.isEmpty) return '$label is required';
        return null;
      },
    );
  }
}
