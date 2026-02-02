import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/services/agency_service.dart';
import 'package:mera_ashiana/models/agency_model.dart';
import 'package:mera_ashiana/theme/app_colors.dart';

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

  final Color yellowAccent = const Color(0xFFFFD54F);

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

  Future<void> _handleSubmission(AppLocalizations loc) async {
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
        SnackBar(
          content: Text(loc.registrationSuccess),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.agencyRegistration,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? yellowAccent : Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildLogoSection(isDark)),
              const SizedBox(height: 40),

              _buildSectionLabel(loc.companyProfile, isDark),
              const SizedBox(height: 12),
              _buildModernField(
                context: context,
                controller: _nameController,
                label: loc.agencyName,
                icon: Icons.business_rounded,
                validator: (v) => v!.isEmpty ? loc.requiredError : null,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                context: context,
                controller: _descController,
                label: loc.businessDescription,
                icon: Icons.info_outline_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _buildSectionLabel(loc.contactDetails, isDark),
              const SizedBox(height: 12),
              _buildModernField(
                context: context,
                controller: _phoneController,
                label: loc.businessPhone,
                icon: Icons.phone_android_rounded,
                validator: (v) => v!.isEmpty ? loc.requiredError : null,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                context: context,
                controller: _emailController,
                label: loc.businessEmail,
                icon: Icons.email_outlined,
                validator: (v) =>
                v != null && v.contains('@') ? null : loc.invalidEmail,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                context: context,
                controller: _addressController,
                label: loc.officeAddress,
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? loc.requiredError : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellowAccent,
                    foregroundColor: AppColors.primaryNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : () => _handleSubmission(loc),
                  child: _isSubmitting
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryNavy,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    loc.registerAgency.toUpperCase(),
                    style: const TextStyle(
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

  Widget _buildSectionLabel(String text, bool isDark) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white60 : AppColors.textGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLogoSection(bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white10 : AppColors.borderGrey,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
            backgroundImage: _selectedLogo != null ? FileImage(_selectedLogo!) : null,
            child: _selectedLogo == null
                ? Icon(
              Icons.store_rounded,
              size: 45,
              color: isDark ? Colors.white24 : AppColors.borderGrey,
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
              decoration: BoxDecoration(
                color: yellowAccent,
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
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? Colors.white : AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : AppColors.textGrey,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? yellowAccent : AppColors.primaryNavy,
          size: 22,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : AppColors.borderGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: yellowAccent, width: 2),
        ),
      ),
    );
  }
}