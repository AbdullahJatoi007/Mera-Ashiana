import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/features/properties/screens/project_details_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

class RecentlyAddedHorizontal extends StatelessWidget {
  final List<Listing> listings;
  final ThemeData theme;
  final bool isDark;

  const RecentlyAddedHorizontal({
    super.key,
    required this.listings,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: If the API sends newest items first, we take the top 6.
    // Removed .reversed to ensure "Recently Added" actually shows newest first.
    final recent = listings.take(6).toList();

    // Prevent rendering an empty space if no listings exist
    if (recent.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final listing = recent[index];

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(listing: listing),
              ),
            ),
            child: Container(
              width: 150, // Slightly wider for better text fit as requested
              margin: const EdgeInsets.only(right: 12, bottom: 4),
              decoration: BoxDecoration(
                color: isDark ? AppDarkColors.surface : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      listing.images.isNotEmpty ? listing.images[0] : '',
                      height: 90,
                      width: 150, // Updated to match container width
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 90,
                        width: 150,
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        child: const Icon(
                          Icons.home_work_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "PKR ${listing.price}",
                          style: TextStyle(
                            color: isDark
                                ? AppDarkColors.accentYellow
                                : AppColors.accentYellow,
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
