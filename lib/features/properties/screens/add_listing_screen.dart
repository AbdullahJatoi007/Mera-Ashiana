import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/services/listing_service.dart';

class AddListingScreen extends StatefulWidget {
  final Listing? listing; // null = create, non-null = edit
  const AddListingScreen({super.key, this.listing});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Image State
  final List<File> _selectedImages = []; // New local files
  List<String> _existingImageUrls = []; // URLs from server (for display)
  List<int> _keepImageIds = []; // IDs to send back to server

  // Dropdown State
  String _selectedType = 'house';
  String _selectedStatus = 'sale';

  final List<Map<String, String>> _propertyTypes = [
    {'value': 'house', 'label': 'House'},
    {'value': 'apartment', 'label': 'Apartment'},
    {'value': 'plot', 'label': 'Plot'},
    {'value': 'commercial', 'label': 'Commercial'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _propertyStatuses = [
    {'value': 'sale', 'label': 'For Sale'},
    {'value': 'rent', 'label': 'For Rent'},
  ];

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
  void initState() {
    super.initState();
    final l = widget.listing;
    if (l != null) {
      _titleController.text = l.title;
      _priceController.text = l.price.toStringAsFixed(0);
      _locationController.text = l.location;
      _descController.text = l.description;
      _phoneController.text = l.contactPhone ?? '';
      _emailController.text = l.contactEmail ?? '';
      _areaController.text = l.area ?? '';
      _bedsController.text = l.bedrooms.toString();
      _bathsController.text = l.bathrooms.toString();
      _selectedType = l.type;
      _selectedStatus = l.status;

      // Load existing images (Assuming the backend/model provides image objects with IDs for tracking)
      // If your 'images' list is just strings, we map them here.
      _existingImageUrls = List<String>.from(l.images);

      // Note: If your backend needs specific IDs to keep,
      // you would ideally have a List<ListingImage> in your model.
      // For now, we'll treat them as existing based on index or URL if necessary.
    }
  }

  @override
  void dispose() {
    for (var c in [
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
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitData(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.listing != null;

    // Requirement: Must have at least one image (either existing or new)
    if (!isEditing && _selectedImages.isEmpty) {
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
      final data = {
        "title": _titleController.text.trim(),
        "price": _priceController.text.trim(),
        "location": _locationController.text.trim(),
        "description": _descController.text.trim(),
        "contact_phone": _phoneController.text.trim(),
        "contact_email": _emailController.text.trim(),
        "area": _areaController.text.trim(),
        "bedrooms": _bedsController.text.trim(),
        "bathrooms": _bathsController.text.trim(),
        "type": _selectedType,
        "status": _selectedStatus,
      };

      Map<String, dynamic> result;

      if (isEditing) {
        result = await ListingService.updateListing(
          id: widget.listing!.id,
          data: data,
          newImageFiles: _selectedImages,
          // If your backend tracks images by URL or Index, adjust this list:
          keepExistingImageIds: _keepImageIds,
        );
      } else {
        result = await ListingService.createListing(
          data: data,
          imageFiles: _selectedImages,
        );
      }

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? "Listing updated!" : "Listing posted!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Operation failed"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color yellow = isDark
        ? AppDarkColors.accentYellow
        : AppColors.accentYellow;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.listing != null ? 'Edit Property' : loc.postProperty,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primaryNavy,
        centerTitle: true,
      ),
      body: Form(
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
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Type',
                      icon: Icons.home_work_outlined,
                      value: _selectedType,
                      items: _propertyTypes,
                      onChanged: (v) => setState(() => _selectedType = v!),
                      isDark: isDark,
                      yellow: yellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Purpose',
                      icon: Icons.sell_outlined,
                      value: _selectedStatus,
                      items: _propertyStatuses,
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                      isDark: isDark,
                      yellow: yellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : Text(
                      widget.listing != null
                          ? 'SAVE CHANGES'
                          : loc.submitAd.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 1. Existing network images
              ..._existingImageUrls.asMap().entries.map((entry) {
                return _buildExistingImageThumbnail(entry.key, entry.value);
              }),
              // 2. New local images
              ..._selectedImages.asMap().entries.map((entry) {
                return _buildImageThumbnail(entry.key);
              }),
              // 3. Add Button
              _buildAddImageButton(isDark, accent, loc),
            ],
          ),
        ),
        if (_existingImageUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Tap × to remove saved images',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExistingImageThumbnail(int index, String url) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _existingImageUrls.removeAt(index)),
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
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'saved',
                style: TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
        ],
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

  Widget _buildAddImageButton(bool isDark, Color accent, AppLocalizations loc) {
    return GestureDetector(
      onTap: () async {
        final pics = await _picker.pickMultiImage();
        if (pics.isNotEmpty)
          setState(() => _selectedImages.addAll(pics.map((e) => File(e.path))));
      },
      child: Container(
        width: 90,
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

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required Color yellow,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: isDark ? AppDarkColors.surface : Colors.white,
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
        prefixIcon: Icon(icon, color: yellow, size: 20),
        filled: true,
        fillColor: isDark ? AppDarkColors.surface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item['value'],
              child: Text(item['label']!),
            ),
          )
          .toList(),
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
}
