import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../shared/helpers/image_picker_helper.dart';
import '../../../shared/helpers/loader_helper.dart';
import '../../../shared/helpers/validation_helper.dart';

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
  bool _isSaving = false; // Added to manage button state internally if needed

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
    final imagePath = await _storage.read(key: 'profile_image_path');

    if (mounted) {
      setState(() {
        _nameController.text = name ?? '';
        _phoneController.text = phone ?? '';
        _emailController.text = email ?? '';
        if (imagePath != null && imagePath.isNotEmpty) {
          _profileImage = File(imagePath);
        }
      });
    }
  }

  Future<void> _handleImagePick() async {
    final File? image = await ImagePickerHelper.pickFromGallery();
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    LoaderHelper.instance.showLoader(context, message: "Updating profile...");

    try {
      // Local caching
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save profile"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yellow = isDark ? AppDarkColors.accentYellow : AppColors.accentYellow;
    final navy = isDark ? AppDarkColors.primaryNavy : AppColors.primaryNavy;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primaryNavy,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatar(isDark, yellow, navy),
              const SizedBox(height: 40),

              _buildModernField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                isDark: isDark,
                yellow: yellow,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Name is required" : null,
              ),
              const SizedBox(height: 16),

              _buildModernField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email_outlined,
                isDark: isDark,
                yellow: yellow,
                keyboardType: TextInputType.emailAddress,
                validator: ValidationHelper.validateEmail,
              ),
              const SizedBox(height: 16),

              _buildModernField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                isDark: isDark,
                yellow: yellow,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 8)
                    ? "Invalid phone number"
                    : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "SAVE CHANGES",
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

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color yellow,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? Colors.white : AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        prefixIcon: Icon(icon, color: yellow, size: 22),
        filled: true,
        fillColor: isDark ? AppDarkColors.surface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : AppColors.borderGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: yellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark, Color yellow, Color navy) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: yellow, width: 2),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: isDark
                  ? AppDarkColors.surface
                  : Colors.grey.shade200,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : null,
              child: _profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 55,
                      color: isDark ? Colors.white24 : Colors.grey,
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: _handleImagePick,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: yellow, width: 1.5),
                ),
                child: Icon(Icons.camera_alt, size: 20, color: yellow),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
