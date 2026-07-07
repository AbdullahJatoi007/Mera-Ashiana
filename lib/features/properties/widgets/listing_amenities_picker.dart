import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

/// Lets the user build up the amenities list via a dropdown: picking an
/// item adds it to [selected] and removes it from the dropdown's
/// remaining options (no duplicates possible). Selected amenities show
/// below as removable chips.
class ListingAmenitiesPicker extends StatelessWidget {
  final List<String> allAmenities;
  final List<String> selected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final bool isDark;
  final Color yellow;

  const ListingAmenitiesPicker({
    super.key,
    required this.allAmenities,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
    required this.isDark,
    required this.yellow,
  });

  @override
  Widget build(BuildContext context) {
    final available = allAmenities.where((a) => !selected.contains(a)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(selected.length),
          // forces reset after each pick
          initialValue: null,
          hint: Text(
            available.isEmpty ? 'All amenities added' : 'Add an amenity',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          onChanged: available.isEmpty
              ? null
              : (v) {
                  if (v != null) onAdd(v);
                },
          dropdownColor: isDark ? AppDarkColors.surface : Colors.white,
          decoration: InputDecoration(
            labelText: 'Amenities',
            labelStyle: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            prefixIcon: Icon(
              Icons.checklist_rtl_outlined,
              color: yellow,
              size: 20,
            ),
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
          items: available
              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
              .toList(),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selected.map((a) {
              return Chip(
                label: Text(a, style: const TextStyle(fontSize: 12)),
                backgroundColor: yellow.withOpacity(0.15),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: yellow.withOpacity(0.4)),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
