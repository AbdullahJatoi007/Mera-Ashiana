import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/services/listing_service.dart';
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

  String _selectedType = 'house';

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one photo"),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    // ... (Your existing submission logic remains the same)
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final Color yellowAccent = const Color(0xFFFFD54F);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Corrected for Dark Mode
      appBar: AppBar(
        title: Text(
          "Post Property",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white
                : Colors.white, // Keeping white for AppBar contrast
          ),
        ),
        backgroundColor: isDark ? colorScheme.surface : AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? yellowAccent : Colors.white),
      ),
      body: _isSubmitting
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? yellowAccent : AppColors.primaryNavy,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionTitle("Property Photos", isDark, yellowAccent),
                  const SizedBox(height: 12),
                  _buildImagePicker(isDark, yellowAccent),
                  const SizedBox(height: 24),

                  _buildSectionTitle("General Details", isDark, yellowAccent),
                  const SizedBox(height: 12),
                  _buildModernField(
                    context: context,
                    controller: _titleController,
                    label: "Title*",
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildModernField(
                          context: context,
                          controller: _priceController,
                          label: "Price*",
                          icon: Icons.money,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
                          context: context,
                          controller: _areaController,
                          label: "Area (sqft)*",
                          icon: Icons.square_foot,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildModernField(
                          context: context,
                          controller: _bedsController,
                          label: "Beds*",
                          icon: Icons.bed,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
                          context: context,
                          controller: _bathsController,
                          label: "Baths*",
                          icon: Icons.bathtub,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    context: context,
                    controller: _locationController,
                    label: "Location*",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    context: context,
                    controller: _descController,
                    label: "Description*",
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    "Contact Information",
                    isDark,
                    yellowAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    context: context,
                    controller: _phoneController,
                    label: "Phone*",
                    icon: Icons.phone_android,
                    isNumber: true,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    context: context,
                    controller: _emailController,
                    label: "Email*",
                    icon: Icons.alternate_email,
                    isEmail: true,
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: yellowAccent,
                      foregroundColor: AppColors.primaryNavy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "SUBMIT AD",
                      style: TextStyle(
                        fontSize: 16,
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

  Widget _buildSectionTitle(String title, bool isDark, Color accent) {
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
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColors.textGrey,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? const Color(0xFFFFD54F) : AppColors.primaryNavy,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : AppColors.borderGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD54F), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }

  Widget _buildImagePicker(bool isDark, Color accent) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, i) {
          if (i == _selectedImages.length) {
            return GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
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
                      "Add",
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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    _selectedImages[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImages.removeAt(i)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
