import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';

class RecentlyAddedHorizontal extends StatelessWidget {
  final List<PropertyModel> properties;
  final ThemeData theme;
  final bool isDark;

  const RecentlyAddedHorizontal({
    super.key,
    required this.properties,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final recent = properties.reversed.take(6).toList();

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final property = recent[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(propertyId: property.id),
              ),
            ),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isDark ? AppDarkColors.surface : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      property.images.isNotEmpty ? property.images[0] : '',
                      height: 90,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(height: 90, color: Colors.grey[400]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "PKR ${property.price}",
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
