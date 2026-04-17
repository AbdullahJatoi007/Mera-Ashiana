import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/listing_model.dart'; // UPDATED: Unified Model
import 'package:mera_ashiana/services/property_service.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/helpers/internet_helper.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';

class PropertiesScreen extends StatelessWidget {
  final List<Listing> listings;
  final String? title;

  const PropertiesScreen({super.key, required this.listings, required this.title});
  @override

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isFilteredView = listings != null;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      appBar: isFilteredView
          ? AppBar(
        title: Text(title ?? 'Properties', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppDarkColors.primaryNavy : AppColors.primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      )
          : null,
      body: FutureBuilder<List<Listing>>( // UPDATED: Type
        future: _fetchProperties(isFilteredView),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.accentYellow));
          }


          final list = snapshot.data!;

          return RefreshIndicator(
            color: AppColors.accentYellow,
            onRefresh: () async {
              bool connected = await InternetHelper.hasInternetConnection();
              if (connected) {
                (context as Element).reassemble();
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) => _buildProjectCard(context, list[index], isDark),
            ),
          );
        },
      ),
    );
  }

  Future<List<Listing>> _fetchProperties(bool isFilteredView) async {
    bool connected = await InternetHelper.hasInternetConnection();
    if (!connected) return [];
    // UPDATED: Cast to the correct Listing type
    return isFilteredView ? Future.value(listings) : PropertyService.fetchProperties();
  }

  Widget _buildProjectCard(BuildContext context, Listing listing, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.08), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProjectDetailsScreen(propertyId: listing.id)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      listing.images.isNotEmpty ? listing.images[0] : '',
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 230, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.status.toUpperCase(),
                          style: const TextStyle(color: AppColors.accentYellow, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppDarkColors.textPrimary : AppColors.primaryNavy)),
                          ),
                          if (listing.isFeatured == 1)
                            const Icon(Icons.verified_rounded, color: AppColors.accentYellow, size: 22),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: AppColors.accentYellow),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(listing.location, style: TextStyle(color: isDark ? AppDarkColors.textSecondary : AppColors.textGrey, fontSize: 13), overflow: TextOverflow.ellipsis),
                          ),
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
}