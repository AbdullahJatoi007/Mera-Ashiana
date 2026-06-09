import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/profile_service.dart';
import '../../../shared/helpers/EmailVerificationDialog.dart';
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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  File? _localImage;
  String? _networkImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = await ProfileService.fetchProfile();
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.username;
        _phoneController.text = user.phone ?? '';
        _emailController.text = user.email;
        _networkImageUrl = user.profileImage;
        _isLoading = false;
      });
    }
  }

  // Logic to handle the Email Change Flow
  Future<void> _handleEmailChangeRequest() async {
    final TextEditingController newEmailController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yellow = isDark ? AppDarkColors.accentYellow : AppColors.accentYellow;
    final navy = isDark ? AppDarkColors.primaryNavy : AppColors.primaryNavy;
    final surface = isDark ? AppDarkColors.surface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    // 1. Show simple dialog to input new email
    final String? newEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Change Email Address",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: newEmailController,
          style: TextStyle(color: textColor),
          cursorColor: yellow,
          decoration: InputDecoration(
            hintText: "Enter new email",
            labelText: "New Email",
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            labelStyle: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: yellow, width: 2),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                Navigator.pop(context, newEmailController.text.trim()),
            child: const Text(
              "Send OTP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (newEmail != null && newEmail.isNotEmpty) {
      if (!ValidationHelper.isEmail(newEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Invalid email format"),
            backgroundColor: isDark
                ? AppDarkColors.errorRed
                : AppColors.errorRed,
          ),
        );
        return;
      }

      LoaderHelper.instance.showLoader(
        context,
        message: "Sending verification code...",
      );

      final error = await ProfileService.sendEmailChangeOtp(newEmail);

      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
        if (error == null) {
          // 2. Open your separate EmailVerificationDialog
          final bool? verified = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => EmailVerificationDialog(newEmail: newEmail),
          );

          if (verified == true) {
            _loadProfileData(); // Refresh email in UI
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Email updated successfully!"),
                backgroundColor: isDark
                    ? AppColors.successGreen
                    : AppColors.successGreen,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: isDark
                  ? AppDarkColors.errorRed
                  : AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleImagePick() async {
    final File? image = await ImagePickerHelper.pickFromGallery();
    if (image != null) {
      setState(() => _localImage = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    LoaderHelper.instance.showLoader(context, message: "Updating profile...");

    try {
      final success = await ProfileService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        imageFile: _localImage,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Update failed"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("UI Catch: $e");
    } finally {
      if (mounted) {
        LoaderHelper.instance.hideLoader(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yellow = isDark ? AppDarkColors.accentYellow : AppColors.accentYellow;
    final navy = isDark ? AppDarkColors.primaryNavy : AppColors.primaryNavy;

    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primaryNavy,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              ),
              const SizedBox(height: 16),

              // Email Field with Update Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildModernField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    yellow: yellow,
                    enabled: false,
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: _handleEmailChangeRequest,
                    icon: Icon(Icons.edit_outlined, size: 16),
                    label: const Text("Change Email"),
                    style: TextButton.styleFrom(
                      foregroundColor: yellow,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildModernField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                isDark: isDark,
                yellow: yellow,
                keyboardType: TextInputType.phone,
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
                  ),
                  child: const Text(
                    "SAVE CHANGES",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Keep your _buildAvatar and _buildModernField methods as they were)
  Widget _buildAvatar(bool isDark, Color yellow, Color navy) {
    ImageProvider? imageProvider;
    if (_localImage != null) {
      imageProvider = FileImage(_localImage!);
    } else if (_networkImageUrl != null) {
      imageProvider = NetworkImage(_networkImageUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: isDark
                ? AppDarkColors.surface
                : Colors.grey.shade200,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 55)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _handleImagePick,
              child: CircleAvatar(
                backgroundColor: navy,
                radius: 18,
                child: Icon(Icons.camera_alt, size: 18, color: yellow),
              ),
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
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: isDark
            ? Colors.white
            : (enabled ? AppColors.textDark : Colors.grey),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        prefixIcon: Icon(icon, color: enabled ? yellow : Colors.grey, size: 22),
        filled: true,
        fillColor: isDark
            ? AppDarkColors.surface
            : (enabled ? Colors.white : Colors.grey.shade100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
      ),
    );
  }
}
