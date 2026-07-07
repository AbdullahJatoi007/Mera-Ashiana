import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import 'image_thumbnail.dart';

/// The full "Property Photos" picker row: shows already-saved image
/// thumbnails, newly-picked local image thumbnails, and an "add" button,
/// all in one horizontally-scrolling strip.
class ImagePickerSection extends StatelessWidget {
  final List<String> existingImageUrls;
  final List<File> selectedImages;
  final void Function(int index) onRemoveExisting;
  final void Function(int index) onRemoveNew;
  final void Function(List<File> newFiles) onImagesPicked;
  final bool isDark;
  final Color accent;
  final AppLocalizations loc;

  const ImagePickerSection({
    super.key,
    required this.existingImageUrls,
    required this.selectedImages,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onImagesPicked,
    required this.isDark,
    required this.accent,
    required this.loc,
  });

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pics = await picker.pickMultiImage();
    if (pics.isNotEmpty) {
      onImagesPicked(pics.map((e) => File(e.path)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
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
              ...existingImageUrls.asMap().entries.map(
                (entry) => ExistingImageThumbnail(
                  url: entry.value,
                  onRemove: () => onRemoveExisting(entry.key),
                ),
              ),
              ...selectedImages.asMap().entries.map(
                (entry) => NewImageThumbnail(
                  file: entry.value,
                  onRemove: () => onRemoveNew(entry.key),
                ),
              ),
              _buildAddImageButton(),
            ],
          ),
        ),
        if (existingImageUrls.isNotEmpty)
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

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
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
}
