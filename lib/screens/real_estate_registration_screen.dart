import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/services/agency_service.dart';
import 'package:mera_ashiana/models/agency_model.dart';

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

  // Controllers for form fields
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

  /// Picks an image from the gallery to use as a logo
  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedLogo = File(image.path));
    }
  }

  /// Validates and submits the registration form
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

      // Return the created Agency object to the previous screen
      Navigator.pop<Agency>(context, result['agency']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Registration failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agency Registration"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLogoSection(theme),
              const SizedBox(height: 30),

              _buildTextField(
                theme,
                controller: _nameController,
                label: "Agency Name",
                icon: Icons.business,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              _buildTextField(
                theme,
                controller: _descController,
                label: "Description",
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 15),

              _buildTextField(
                theme,
                controller: _phoneController,
                label: "Phone",
                icon: Icons.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              _buildTextField(
                theme,
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                validator: (v) =>
                    v != null && v.contains('@') ? null : "Invalid email",
              ),
              const SizedBox(height: 15),

              _buildTextField(
                theme,
                controller: _addressController,
                label: "Address",
                icon: Icons.location_on,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmission,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTER AGENCY"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(ThemeData theme) {
    return GestureDetector(
      onTap: _pickLogo,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        backgroundImage: _selectedLogo != null
            ? FileImage(_selectedLogo!)
            : null,
        child: _selectedLogo == null
            ? Icon(Icons.camera_alt, size: 35, color: theme.primaryColor)
            : null,
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
