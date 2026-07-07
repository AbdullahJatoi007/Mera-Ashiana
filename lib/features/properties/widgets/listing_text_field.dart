import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

/// Reusable styled text field used across the listing form.
///
/// Pass [inputFormatters] to restrict what characters can be typed
/// (e.g. digits only for beds/baths/price), and [validator] for
/// field-specific validation logic.
class ListingTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final Color yellow;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const ListingTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.yellow,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
