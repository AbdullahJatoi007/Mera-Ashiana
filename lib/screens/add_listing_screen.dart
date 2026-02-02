import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;
  List<File> _selectedImages = [];

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

  void _submitData(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.photoError), // Localized Error
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    // Submission logic here...
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final Color yellowAccent = const Color(0xFFFFD54F);

    // The "loc" helper
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.postProperty, // Localized Title
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? colorScheme.surface : AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? yellowAccent : Colors.white),
      ),
      body: _isSubmitting
          ? Center(child: CircularProgressIndicator(color: yellowAccent))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionTitle(loc.propertyPhotos, isDark),
                  const SizedBox(height: 12),
                  _buildImagePicker(isDark, yellowAccent, loc),
                  const SizedBox(height: 24),

                  _buildSectionTitle(loc.generalDetails, isDark),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _titleController,
                    label: loc.title,
                    icon: Icons.title_rounded,
                    errorMsg: loc.requiredError,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildModernField(
                          controller: _priceController,
                          label: loc.price,
                          icon: Icons.money,
                          isNumber: true,
                          errorMsg: loc.requiredError,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
                          controller: _areaController,
                          label: loc.area,
                          icon: Icons.square_foot,
                          errorMsg: loc.requiredError,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildModernField(
                          controller: _bedsController,
                          label: loc.beds,
                          icon: Icons.bed,
                          isNumber: true,
                          errorMsg: loc.requiredError,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
                          controller: _bathsController,
                          label: loc.baths,
                          icon: Icons.bathtub,
                          isNumber: true,
                          errorMsg: loc.requiredError,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _locationController,
                    label: loc.location,
                    icon: Icons.location_on_outlined,
                    errorMsg: loc.requiredError,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _descController,
                    label: loc.description,
                    icon: Icons.description_outlined,
                    maxLines: 3,
                    errorMsg: loc.requiredError,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(loc.contactInformation, isDark),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _phoneController,
                    label: loc.phone,
                    icon: Icons.phone_android,
                    isNumber: true,
                    errorMsg: loc.requiredError,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _emailController,
                    label: loc.email,
                    icon: Icons.alternate_email,
                    isEmail: true,
                    errorMsg: loc.requiredError,
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () => _submitData(loc),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: yellowAccent,
                      foregroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      loc.submitAd.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // --- Helper Methods ---

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.primaryNavy,
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String errorMsg, // Pass the translation
    bool isNumber = false,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: isDark ? const Color(0xFFFFD54F) : AppColors.primaryNavy,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? errorMsg : null,
    );
  }

  Widget _buildImagePicker(bool isDark, Color accent, AppLocalizations loc) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, i) {
          if (i == _selectedImages.length) {
            return GestureDetector(
              onTap: () async {
                final pics = await _picker.pickMultiImage();
                if (pics.isNotEmpty) {
                  setState(
                    () => _selectedImages.addAll(pics.map((e) => File(e.path))),
                  );
                }
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isDark ? Colors.white10 : AppColors.borderGrey,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: accent),
                    const SizedBox(height: 4),
                    Text(
                      loc.add,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                _selectedImages[i],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
