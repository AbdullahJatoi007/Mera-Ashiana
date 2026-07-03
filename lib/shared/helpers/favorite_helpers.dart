import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/features/properties/screens/project_details_screen.dart';
import 'package:mera_ashiana/data/services/FavoriteService.dart';

import '../../core/theme/app_colors.dart';

class FavoriteHelpers {
  static Widget buildFavoriteCard(BuildContext context, Listing item) {
    return _FavoriteCard(item: item);
  }
}

class _FavoriteCard extends StatefulWidget {
  final Listing item;

  const _FavoriteCard({required this.item});

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard> {
  bool _isToggling = false;

  Future<void> _handleUnfavorite() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);
    try {
      await FavoriteService.toggleFavorite(widget.item.id);
      // On success the FavouritesScreen's ValueListenableBuilder (listening
      // to FavoriteService.favoriteIds) rebuilds automatically and this
      // card disappears from the list — no local state change needed here.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't remove favorite. Please check your connection.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
                          item.location,
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),

                  // ❤️ FAVORITE BUTTON (always shown filled — every card in
                  // this list is, by definition, already favorited)
                  IconButton(
                    icon: _isToggling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.favorite, color: Colors.red),
                    onPressed: _isToggling ? null : _handleUnfavorite,
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
