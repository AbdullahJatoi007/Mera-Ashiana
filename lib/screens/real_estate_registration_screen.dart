import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/services/agency_service.dart';

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

  // 1. Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ceoController =
      TextEditingController(); // Principal Name
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController =
      TextEditingController(); // City/Areas
  final TextEditingController _descController = TextEditingController();

  // 2. State Variables
  String _agencyType = 'Agency';
  File? _selectedLogo;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ceoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // 3. Picking Image Logic
  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedLogo = File(image.path);
      });
    }
  }

  // 4. Submit Logic
  void _handleSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Note: CEO name and Description are combined or mapped based on your backend needs
    final result = await AgencyService.registerAgency(
      agencyName: _nameController.text,
      email: _emailController.text,
      description: "CEO: ${_ceoController.text}. ${_descController.text}",
      phone: _phoneController.text,
      address: _addressController.text,
      logoFile: _selectedLogo,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Partner Registration",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressHeader(theme),
              const SizedBox(height: 30),
              _buildLogoSection(theme),
              const SizedBox(height: 30),
              _buildSectionTitle(theme, "I am a..."),
              _buildTypeSelector(theme),
              const SizedBox(height: 25),
              _buildSectionTitle(theme, "Business Details"),
              _buildTextField(
                theme,
                controller: _nameController,
                label: "Agency / Company Name",
                icon: Icons.business,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                controller: _ceoController,
                label: "CEO / Principal Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                controller: _descController,
                label: "Brief Description",
                icon: Icons.description_outlined,
                hint: "Tell us about your agency",
              ),
              const SizedBox(height: 25),
              _buildSectionTitle(theme, "Contact Information"),
              _buildTextField(
                theme,
                controller: _phoneController,
                label: "Mobile Number",
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email_outlined,
                validator: (v) => v!.contains('@') ? null : "Invalid Email",
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                controller: _addressController,
                label: "City / Service Areas",
                icon: Icons.map_outlined,
                hint: "e.g., Karachi, Lahore",
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SUBMIT FOR VERIFICATION",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildLogoSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickLogo,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: theme.colorScheme.surface,
              backgroundImage: _selectedLogo != null
                  ? FileImage(_selectedLogo!)
                  : null,
              child: _selectedLogo == null
                  ? Icon(
                      Icons.add_business_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    )
                  : null,
            ),
          ),
          TextButton(
            onPressed: _pickLogo,
            child: Text(
              _selectedLogo == null ? "Upload Agency Logo" : "Change Logo",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // (ProgressHeader, TypeSelector, and SectionTitle helper methods stay the same as your original UI)
  Widget _buildProgressHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Your details will be verified by our team within 24-48 hours.",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    final types = ["Agency", "Developer", "Freelancer"];
    return Wrap(
      spacing: 10,
      children: types
          .map(
            (type) => ChoiceChip(
              label: Text(type),
              selected: _agencyType == type,
              onSelected: (val) => setState(() => _agencyType = type),
            ),
          )
          .toList(),
    );
  }
}
