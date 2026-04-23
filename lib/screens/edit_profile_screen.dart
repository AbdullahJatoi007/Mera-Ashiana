import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Imports for your helpers
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/helpers/image_picker_helper.dart';
import 'package:mera_ashiana/helpers/loader_helper.dart';
import 'package:mera_ashiana/helpers/validation_helper.dart';

// ADDED: ApiClient and Endpoints for backend sync
import 'package:mera_ashiana/core/api_client.dart';
import 'package:mera_ashiana/network/endpoints.dart';

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
  final _emailController = TextEditingController();

  File? _profileImage;
  String? _savedImagePath; // To keep track of the locally saved image path

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
    final imagePath = await _storage.read(
      key: 'profile_image_path',
    ); // Load image

    setState(() {
      _nameController.text = name ?? '';
      _phoneController.text = phone ?? '';
      _emailController.text = email ?? '';

      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
        _savedImagePath = imagePath;
      }
    });
  }

  Future<void> _handleImagePick() async {
    final File? image = await ImagePickerHelper.pickFromGallery();
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Close keyboard
    LoaderHelper.instance.showLoader(context, message: "Updating profile...");

    try {
      // 1. UPDATE BACKEND (Uncomment and adjust based on your ApiClient)
      /*
      final response = await ApiClient.post(
        Endpoints.updateProfile,
        body: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
        },
      );

      if (response.statusCode != 200) {
         throw Exception("Failed to update on server");
      }
      */

      // Note: If you are uploading the image to the server, you will need a
      // MultipartRequest here via your ApiClient.

      // 2. UPDATE LOCAL STORAGE (Cache)
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

      // Save the image path so it persists on app restart
      if (_profileImage != null) {
        await _storage.write(
          key: 'profile_image_path',
          value: _profileImage!.path,
        );
      }

      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        _showError("Failed to save profile. Please try again.");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatar(),
              const SizedBox(height: 40),

              // Name Field
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? "Name is required"
                    : null,
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: ValidationHelper.validateEmail,
              ),
              const SizedBox(height: 20),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => (value == null || value.trim().length < 8)
                    ? "Invalid phone number"
                    : null,
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "SAVE CHANGES",
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentYellow, width: 3),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.withOpacity(0.2),
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : null,
              child: _profileImage == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: _handleImagePick,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: AppColors.accentYellow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
