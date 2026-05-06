import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart'; // Ensure AppDarkColors is inside here
import 'package:mera_ashiana/core/network/api_client.dart';

import '../../../core/theme/app_colors_dark.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  final List<File> _selectedImages = [];

  // Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _areaController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();

  @override
  void dispose() {
    for (var controller in [
      _titleController,
      _priceController,
      _locationController,
      _descController,
      _phoneController,
      _emailController,
      _areaController,
      _bedsController,
      _bathsController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitData(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.photoError),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      List<MultipartFile> imageFiles = [];
      for (var file in _selectedImages) {
        imageFiles.add(await MultipartFile.fromFile(file.path));
      }

      final formData = FormData.fromMap({
        "title": _titleController.text.trim(),
        "price": _priceController.text.trim(),
        "location": _locationController.text.trim(),
        "description": _descController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "area": _areaController.text.trim(),
        "bedrooms": _bedsController.text.trim(),
        "bathrooms": _bathsController.text.trim(),
        "images": imageFiles,
      });

      final response = await ApiClient.dio.post(
        '/listings/add',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Listing posted successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to post listing."),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color yellow = isDark
        ? AppDarkColors.accentYellow
        : AppColors.accentYellow;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      appBar: AppBar(
        title: Text(
          loc.postProperty,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primaryNavy,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildImagePicker(isDark, yellow, loc),
                const SizedBox(height: 20),

                _buildSection(loc.generalDetails, isDark, [
                  _buildModernField(
                    controller: _titleController,
                    label: loc.title,
                    icon: Icons.title,
                    errorMsg: loc.requiredError,
                    isDark: isDark,
                    yellow: yellow,
                  ),
                  const SizedBox(height: 12),
                  // Responsive Row 1: Price and Area
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernField(
                          controller: _priceController,
                          label: loc.price,
                          icon: Icons.payments_outlined,
                          isNumber: true,
                          errorMsg: loc.requiredError,
                          isDark: isDark,
                          yellow: yellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
                          controller: _areaController,
                          label: loc.area,
                          icon: Icons.straighten,
                          errorMsg: loc.requiredError,
                          isDark: isDark,
                          yellow: yellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Responsive Row 2: Beds and Baths
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernField(
                          controller: _bedsController,
                          label: loc.beds,
                          icon: Icons.king_bed_outlined,
                          isNumber: true,
                          errorMsg: loc.requiredError,
                          isDark: isDark,
                          yellow: yellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
                          controller: _bathsController,
                          label: loc.baths,
                          icon: Icons.bathtub_outlined,
                          isNumber: true,
                          errorMsg: loc.requiredError,
                          isDark: isDark,
                          yellow: yellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _locationController,
                    label: loc.location,
                    icon: Icons.place_outlined,
                    errorMsg: loc.requiredError,
                    isDark: isDark,
                    yellow: yellow,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _descController,
                    label: loc.description,
                    icon: Icons.notes,
                    maxLines: 3,
                    errorMsg: loc.requiredError,
                    isDark: isDark,
                    yellow: yellow,
                  ),
                ]),

                const SizedBox(height: 20),
                _buildSection(loc.contactInformation, isDark, [
                  _buildModernField(
                    controller: _phoneController,
                    label: loc.phone,
                    icon: Icons.phone_iphone,
                    isNumber: true,
                    errorMsg: loc.requiredError,
                    isDark: isDark,
                    yellow: yellow,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _emailController,
                    label: loc.email,
                    icon: Icons.email_outlined,
                    isEmail: true,
                    errorMsg: loc.requiredError,
                    isDark: isDark,
                    yellow: yellow,
                  ),
                ]),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitData(loc),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: yellow,
                    foregroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          loc.submitAd.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.primaryNavy,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String errorMsg,
    required bool isDark,
    required Color yellow,
    bool isNumber = false,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIcon: Icon(icon, color: yellow, size: 20),
        filled: true,
        fillColor: isDark ? AppDarkColors.surface : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : AppColors.borderGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: yellow, width: 1.5),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? errorMsg : null,
    );
  }

  Widget _buildImagePicker(bool isDark, Color accent, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            loc.propertyPhotos,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.primaryNavy,
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, i) {
              if (i == _selectedImages.length) {
                return _buildAddImageButton(isDark, accent, loc);
              }
              return _buildImageThumbnail(i);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(bool isDark, Color accent, AppLocalizations loc) {
    return GestureDetector(
      onTap: () async {
        final pics = await _picker.pickMultiImage();
        if (pics.isNotEmpty)
          setState(() => _selectedImages.addAll(pics.map((e) => File(e.path))));
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : AppColors.borderGrey,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: accent, size: 24),
            const SizedBox(height: 4),
            Text(
              loc.add,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_selectedImages[index], fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImages.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
