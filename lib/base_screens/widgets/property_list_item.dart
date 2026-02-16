import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';

class PropertyListItem extends StatelessWidget {
  final PropertyModel property;
  final ThemeData theme;
  final bool isDark;

  const PropertyListItem({
    super.key,
    required this.property,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(propertyId: property.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.surface : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'property_${property.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property.images.isNotEmpty ? property.images[0] : '',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 90, height: 90, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    property.location,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "PKR ${property.price}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
