import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/features/properties/screens/project_details_screen.dart';
import 'package:mera_ashiana/data/services/FavoriteService.dart';

import '../../core/theme/app_colors.dart';

class FavoriteHelpers {
  // ✅ UPDATED: now uses Listing
  static Widget buildFavoriteCard(BuildContext context, Listing item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailsScreen(listing: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ IMAGE
            if (item.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  item.images[0],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: AppColors.accentYellow,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            // ✅ DETAILS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "PKR ${item.price}",
                          style: const TextStyle(
                            color: AppColors.accentYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.location ?? '',
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),

                  // ❤️ FAVORITE BUTTON
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      FavoriteService.toggleFavorite(item.id);
                    },
                  ),
                ],
              ),
            ),

            // ✅ EXTRA INFO
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${item.bedrooms} Beds | ${item.bathrooms} Baths | ${item.area ?? ''}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentYellow,
                      ),
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
