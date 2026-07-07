import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Wraps a labeled group of form fields (e.g. "General Details",
/// "Contact Information") with a consistent section title style.
class ListingSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const ListingSection({
    super.key,
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
}
