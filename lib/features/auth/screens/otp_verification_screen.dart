import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import 'package:mera_ashiana/data/services/auth/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 4) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.verifyOtpAndRegister(email: widget.email, otp: otp);
      widget.onVerified();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Verify your Email",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("Code sent to ${widget.email}"),
        const SizedBox(height: 30),

        // OTP Input Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => _buildOtpBox(index)),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Verify & Register",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryNavy, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 3 && value.isNotEmpty) {
            _verifyOtp(); // Auto-submit on last digit
          }
        },
      ),
    );
  }
}
