import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Imports for your helpers
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/helpers/image_picker_helper.dart';
import 'package:mera_ashiana/helpers/loader_helper.dart';
import 'package:mera_ashiana/helpers/validation_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController =
      TextEditingController(); // Added for ValidationHelper demo

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final name = await _storage.read(key: 'user_name');
    final phone = await _storage.read(key: 'user_phone');
    final email = await _storage.read(key: 'user_email');

    setState(() {
      _nameController.text = name ?? '';
      _phoneController.text = phone ?? '';
      _emailController.text = email ?? '';
    });
  }

  Future<void> _handleImagePick() async {
    // Using your ImagePickerHelper
    final File? image = await ImagePickerHelper.pickFromGallery();
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Using your LoaderHelper
    LoaderHelper.instance.showLoader(context, message: "Updating profile...");

    try {
      await _storage.write(
        key: 'user_name',
        value: _nameController.text.trim(),
      );
      await _storage.write(
        key: 'user_phone',
        value: _phoneController.text.trim(),
      );
      await _storage.write(
        key: 'user_email',
        value: _emailController.text.trim(),
      );

      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved successfully!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) LoaderHelper.instance.hideLoader(context);
      _showError("Failed to save profile");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatar(),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Name is required"
                    : null,
              ),
              const SizedBox(height: 16),

              // Email Field using your ValidationHelper
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
                validator: ValidationHelper.validateEmail,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.length < 8)
                    ? "Invalid phone number"
                    : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                  ),
                  child: const Text(
                    "SAVE CHANGES",
                    style: TextStyle(color: AppColors.primaryNavy),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : null,
          child: _profileImage == null
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton.small(
            onPressed: _handleImagePick,
            backgroundColor: AppColors.accentYellow,
            child: const Icon(
              Icons.camera_alt,
              size: 18,
              color: AppColors.primaryNavy,
            ),
          ),
        ),
      ],
    );
  }
}
