import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/services/agency_service.dart';
import 'package:mera_ashiana/models/agency_model.dart';

// Using your AppColors Palette
class AppColors {
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF0A1D37);
  static const Color textGrey = Color(0xFF757575);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color errorRed = Color(0xFFD32F2F);
}

class RealEstateRegistrationScreen extends StatefulWidget {
  const RealEstateRegistrationScreen({super.key});

  @override
  State<RealEstateRegistrationScreen> createState() =>
      _RealEstateRegistrationScreenState();
}

class _RealEstateRegistrationScreenState
    extends State<RealEstateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _selectedLogo;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    HapticFeedback.lightImpact();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedLogo = File(image.path));
    }
  }

  Future<void> _handleSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final result = await AgencyService.registerAgency(
      agencyName: _nameController.text,
      description: _descController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      logoFile: _selectedLogo,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true && result['agency'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agency registered successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop<Agency>(context, result['agency']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Registration failed"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Agency Registration",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildLogoSection()),
              const SizedBox(height: 40),

              _buildSectionLabel("Company Profile"),
              const SizedBox(height: 12),
              _buildModernField(
                controller: _nameController,
                label: "Agency Name",
                icon: Icons.business_rounded,
                validator: (v) => v!.isEmpty ? "Enter agency name" : null,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: _descController,
                label: "Business Description",
                icon: Icons.info_outline_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _buildSectionLabel("Contact Details"),
              const SizedBox(height: 12),
              _buildModernField(
                controller: _phoneController,
                label: "Business Phone",
                icon: Icons.phone_android_rounded,
                validator: (v) => v!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: _emailController,
                label: "Business Email",
                icon: Icons.email_outlined,
                validator: (v) =>
                    v != null && v.contains('@') ? null : "Enter a valid email",
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: _addressController,
                label: "Office Address",
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? "Enter address" : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: AppColors.primaryNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmission,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryNavy,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "REGISTER AGENCY",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLogoSection() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGrey, width: 2),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.background,
            backgroundImage: _selectedLogo != null
                ? FileImage(_selectedLogo!)
                : null,
            child: _selectedLogo == null
                ? const Icon(
                    Icons.store_rounded,
                    size: 45,
                    color: AppColors.borderGrey,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickLogo,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.accentYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 20,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: AppColors.textDark),
      cursorColor: AppColors.primaryNavy,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.primaryNavy, size: 22),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.accentYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),
    );
  }
}
