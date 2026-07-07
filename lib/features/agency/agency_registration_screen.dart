import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/data/services/agency_service.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart'; // Ensure AppDarkColors is imported or accessible here
import '../../core/theme/app_colors_dark.dart';
import '../../data/models/agency_model.dart';

class RealEstateRegistrationScreen extends StatefulWidget {
  final Agency? agency;

  const RealEstateRegistrationScreen({super.key, this.agency});

  @override
  State<RealEstateRegistrationScreen> createState() =>
      _RealEstateRegistrationScreenState();
}

class _RealEstateRegistrationScreenState
    extends State<RealEstateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  File? _selectedLogo;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final a = widget.agency;
    _nameController = TextEditingController(text: a?.agencyName ?? '');
    _descController = TextEditingController(text: a?.description ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _emailController = TextEditingController(text: a?.email ?? '');
    _addressController = TextEditingController(text: a?.address ?? '');
  }

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
    if (image != null) setState(() => _selectedLogo = File(image.path));
  }

  Future<void> _handleSubmission(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final isEditing = widget.agency != null;
      final result = isEditing
          ? await AgencyService.updateAgency(
              agencyName: _nameController.text,
              description: _descController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              address: _addressController.text,
              logoFile: _selectedLogo,
            )
          : await AgencyService.registerAgency(
              agencyName: _nameController.text,
              description: _descController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              address: _addressController.text,
              logoFile: _selectedLogo,
            );

      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? "Updated successfully" : loc.registrationSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Operation failed"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unexpected error: $e"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final isEditing = widget.agency != null;

    // Theme-based colors
    final yellow = isDark ? AppDarkColors.accentYellow : AppColors.accentYellow;
    final navy = isDark ? AppDarkColors.primaryNavy : AppColors.primaryNavy;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Agency" : loc.agencyRegistration,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primaryNavy,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLogoSection(isDark, yellow),
              const SizedBox(height: 30),
              _buildModernField(
                controller: _nameController,
                label: loc.agencyName,
                icon: Icons.business_rounded,
                isDark: isDark,
                yellow: yellow,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: _descController,
                label: loc.businessDescription,
                icon: Icons.info_outline_rounded,
                maxLines: 3,
                isDark: isDark,
                yellow: yellow,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: _phoneController,
                label: loc.businessPhone,
                icon: Icons.phone_android_rounded,
                isDark: isDark,
                yellow: yellow,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: _emailController,
                label: loc.businessEmail,
                icon: Icons.email_outlined,
                isDark: isDark,
                yellow: yellow,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildModernField(
                controller: _addressController,
                label: loc.officeAddress,
                icon: Icons.location_on_outlined,
                isDark: isDark,
                yellow: yellow,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: navy, // Text color inside the button
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => _handleSubmission(loc),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: navy,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'SAVE CHANGES'
                              : loc.registerAgency.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool isDark, Color yellow) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppDarkColors.surface : AppColors.borderGrey,
            ),
            child: ClipOval(
              child: _selectedLogo != null
                  ? Image.file(_selectedLogo!, fit: BoxFit.cover)
                  : (widget.agency?.logo != null
                        ? CachedNetworkImage(
                            imageUrl: widget.agency!.logo!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.store_rounded, size: 45),
                          )
                        : const Icon(Icons.store_rounded, size: 45)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: _pickLogo,
              icon: Icon(Icons.camera_alt, color: yellow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color yellow,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
      // Text color inside the input
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColors.textGrey,
        ),
        prefixIcon: Icon(icon, color: yellow),
        filled: true,
        fillColor: isDark ? AppDarkColors.surface : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark ? AppDarkColors.borderGrey : AppColors.borderGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: yellow,
            width: 2,
          ), // Yellow color when focused
        ),
      ),
    );
  }
}
