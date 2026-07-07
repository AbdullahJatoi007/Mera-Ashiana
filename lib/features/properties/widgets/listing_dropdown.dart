import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import 'listing_text_field.dart';

/// Sentinel value representing the "Other (type manually)" choice when
/// [ListingDropdown.enableOther] is true.
const String kOtherOptionValue = '__other__';

/// A single reusable dropdown for the listing form.
///
/// For a plain fixed-choice dropdown (Type, Purpose, Preferred Contact),
/// just use it as before — pass [items], [value], [onChanged].
///
/// For a dropdown that also needs a manual-entry fallback (City,
/// Province), set [enableOther] to true and supply [otherController].
/// An "Other (type manually)" option is appended automatically, and
/// selecting it reveals a text field underneath for free entry.
class ListingDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final bool isDark;
  final Color yellow;

  // Optional "Other, type manually" support.
  final bool enableOther;
  final TextEditingController? otherController;
  final String? Function(String?)? otherValidator;

  const ListingDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    required this.yellow,
    this.enableOther = false,
    this.otherController,
    this.otherValidator,
  }) : assert(
         !enableOther || otherController != null,
         'otherController is required when enableOther is true',
       );

  @override
  Widget build(BuildContext context) {
    final effectiveItems = enableOther
        ? [
            ...items,
            {'value': kOtherOptionValue, 'label': 'Other (type manually)'},
          ]
        : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: value,
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
          items: effectiveItems
              .map(
                (item) => DropdownMenuItem(
                  value: item['value'],
                  child: Text(item['label']!),
                ),
              )
              .toList(),
        ),
        if (enableOther && value == kOtherOptionValue) ...[
          const SizedBox(height: 12),
          ListingTextField(
            controller: otherController!,
            label: 'Enter $label',
            icon: Icons.edit_outlined,
            isDark: isDark,
            yellow: yellow,
            validator: otherValidator,
          ),
        ],
      ],
    );
  }
}
