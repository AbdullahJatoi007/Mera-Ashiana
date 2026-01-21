import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/services/agency_service.dart';
import 'package:mera_ashiana/screens/AgencyStatusScreen.dart';

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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedLogo = File(image.path));
    }
  }

  /// Merged Submission Logic
  void _handleSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Call service with all form data
    final result = await AgencyService.registerAgency(
      agencyName: _nameController.text,
      description: _descController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      logoFile: _selectedLogo,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (result['success']) {
        // 1. Show Success Message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Agency registered successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // 2. Navigate to Status Screen
        // We use pushReplacement so they can't go back to the registration form
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AgencyStatusScreen(),
            // If your AgencyStatusScreen takes an agency object, pass it like this:
            // settings: RouteSettings(arguments: result['agency']),
          ),
        );
      } else {
        // 3. Show Error Message from API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Registration failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Agency Registration"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v != null && v.contains('@')) ? null : "Invalid Email",
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
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmission,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
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
    return Column(
      children: [
        GestureDetector(
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
        ),
        const SizedBox(height: 8),
        const Text(
          "Upload Agency Logo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
      ),
    );
  }
}
