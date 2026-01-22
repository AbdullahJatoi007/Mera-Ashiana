import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/services/listing_service.dart';

// Palette Class (as defined previously)
class AppColors {
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF0A1D37);
  static const Color textGrey = Color(0xFF757575);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color errorRed = Color(0xFFD32F2F);
}

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

    final Map<String, dynamic> body = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "price": _priceController.text.trim(),
      "location": _locationController.text.trim(),
      "type": _selectedType,
      "bedrooms": _bedsController.text.trim(),
      "bathrooms": _bathsController.text.trim(),
      "area": _areaController.text.trim(),
      "status": "sale",
      "province": "Sindh",
      "city": "Karachi",
      "zipCode": "75600",
      "contactPhone": _phoneController.text.trim(),
      "contactEmail": _emailController.text.trim(),
      "preferredContact": "phone",
    };

    final result = await ListingService.createListing(
      data: body,
      imageFiles: _selectedImages,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Property posted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Upload failed"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Post Property",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryNavy),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionTitle("Property Photos"),
                  const SizedBox(height: 12),
                  _buildImagePicker(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("General Details"),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _titleController,
                    label: "Title*",
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildModernField(
                          controller: _priceController,
                          label: "Price*",
                          icon: Icons.money,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
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
                          controller: _bedsController,
                          label: "Beds*",
                          icon: Icons.bed,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernField(
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
                    controller: _locationController,
                    label: "Location*",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _descController,
                    label: "Description*",
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Contact Information"),
                  const SizedBox(height: 12),
                  _buildModernField(
                    controller: _phoneController,
                    label: "Phone*",
                    icon: Icons.phone_android,
                    isNumber: true,
                  ),
                  const SizedBox(height: 12),
                  _buildModernField(
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
                      backgroundColor: AppColors.accentYellow,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryNavy,
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primaryNavy, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }

  Widget _buildImagePicker() {
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
                  setState(() {
                    _selectedImages.addAll(pics.map((e) => File(e.path)));
                  });
                }
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.borderGrey,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primaryNavy,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryNavy,
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
