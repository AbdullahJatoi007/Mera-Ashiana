import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/property_category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

class CategoryList extends StatelessWidget {
  final List<PropertyCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryList({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              showCheckmark: false,
              label: Text(category.label),
              avatar: Icon(
                category.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppDarkColors.accentYellow
                          : AppColors.primaryNavy),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(index),
              backgroundColor: isDark ? AppDarkColors.surface : AppColors.white,
              selectedColor: isDark
                  ? AppDarkColors.accentYellow
                  : AppColors.primaryNavy,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
