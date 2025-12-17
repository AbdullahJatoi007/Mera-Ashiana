import 'package:flutter/material.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart' hide LoginScreen;
import 'package:mera_ashiana/theme/app_colors.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _acceptedTerms = false; // Checkbox state
  int _selectedRoleIndex = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // New

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryNavy),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Header
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text('Join Ashiana to find your perfect home', style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
                const SizedBox(height: 24),

                // 3. Role Selector
                _buildRoleSelector(),
                const SizedBox(height: 24),

                // 4. Input Fields
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isConfirmField: false,
                  validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // 5. Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                  isConfirmField: true,
                  validator: (value) {
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 6. Terms and Conditions Checkbox
                FormField<bool>(
                  initialValue: _acceptedTerms,
                  validator: (value) => _acceptedTerms == false ? 'You must accept terms' : null,
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24, width: 24,
                              child: Checkbox(
                                value: _acceptedTerms,
                                activeColor: AppColors.primaryNavy,
                                checkColor: AppColors.accentYellow,
                                onChanged: (val) => setState(() => _acceptedTerms = val!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'I have read and accept terms & privacy policy',
                                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 36),
                            child: Text(state.errorText!, style: const TextStyle(color: AppColors.errorRed, fontSize: 12)),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 7. Register Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Signup Logic
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: AppColors.primaryNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _selectedRoleIndex == 0 ? 'REGISTER AS USER' : 'REGISTER AS AGENT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 24),

                // 8. Social Login
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Or register with", style: TextStyle(color: AppColors.textGrey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, color: AppColors.primaryNavy, size: 30),
                  label: const Text('Continue with Google', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.borderGrey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),

                // 9. Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: AppColors.textGrey)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                      child: const Text('Login', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
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

  // --- REFACTORED HELPERS ---

  Widget _buildRoleSelector() {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
        child: ToggleButtons(
          isSelected: [_selectedRoleIndex == 0, _selectedRoleIndex == 1],
          onPressed: (index) => setState(() => _selectedRoleIndex = index),
          borderRadius: BorderRadius.circular(8),
          selectedColor: AppColors.primaryNavy,
          fillColor: AppColors.accentYellow,
          color: AppColors.textGrey,
          renderBorder: false,
          constraints: BoxConstraints.expand(width: (constraints.maxWidth / 2) - 4, height: 48),
          children: const [
            Text('User', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Agent', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? isConfirmField, // Helps toggle the correct visibility variable
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    bool obscure = isPassword ? (isConfirmField == true ? _isConfirmObscured : _isObscured) : false;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primaryNavy),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.primaryNavy),
          onPressed: () {
            setState(() {
              if (isConfirmField == true) {
                _isConfirmObscured = !_isConfirmObscured;
              } else {
                _isObscured = !_isObscured;
              }
            });
          },
        )
            : null,
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentYellow, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGrey)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorRed)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorRed, width: 2)),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}