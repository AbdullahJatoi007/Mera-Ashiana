import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

class ListingDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool isDark;
  final Color yellow;

  const ListingDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    required this.yellow,
  });

  @override
  Widget build(BuildContext context) {
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
}
