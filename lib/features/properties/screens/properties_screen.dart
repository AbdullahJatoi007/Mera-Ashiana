import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/data/services/property_service.dart';
import 'package:mera_ashiana/features/properties/screens/project_details_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../shared/helpers/internet_helper.dart';

class PropertiesScreen extends StatelessWidget {
  final List<Listing>? listings;
  final String? title;

  const PropertiesScreen({super.key, this.listings, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isFilteredView = listings != null && listings!.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      // ✅ REMOVED: AppBar removed to prevent double headings
      body: FutureBuilder<List<Listing>>(
        future: _fetchProperties(isFilteredView),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentYellow),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final list = snapshot.data!;

          return RefreshIndicator(
            color: AppColors.accentYellow,
            onRefresh: () async {
              (context as Element).reassemble();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              // Added top padding since AppBar is gone
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) =>
                  _buildProjectCard(context, list[index], isDark),
            ),
          );
        },
      ),
    );
  }

  Future<List<Listing>> _fetchProperties(bool isFilteredView) async {
    bool connected = await InternetHelper.hasInternetConnection();
    if (!connected) return [];
    return isFilteredView ? listings! : PropertyService.fetchProperties();
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("No properties found", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Listing listing, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(propertyId: listing.id),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      listing.images.isNotEmpty ? listing.images[0] : '',
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildBadge(
                        listing.status.toUpperCase(),
                        AppColors.primaryNavy,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _buildBadge(
                        "PKR ${listing.price.toStringAsFixed(0)}",
                        AppColors.accentYellow,
                        textColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              listing.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppDarkColors.textPrimary
                                    : AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          if (listing.isFeatured)
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.location,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _cardSpec(Icons.bed, "${listing.bedrooms} Beds"),
                          _cardSpec(
                            Icons.bathtub,
                            "${listing.bathrooms} Baths",
                          ),
                          _cardSpec(Icons.square_foot, listing.area ?? "N/A"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    String text,
    Color color, {
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _cardSpec(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentYellow),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
