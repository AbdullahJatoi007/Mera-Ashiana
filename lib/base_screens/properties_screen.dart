import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/services/property_service.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';

// Brand Palette
class AppColors {
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF757575);
}

class PropertiesScreen extends StatelessWidget {
  final List<PropertyModel>? properties;
  final String? title;

  const PropertiesScreen({super.key, this.properties, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final bool isFilteredView = properties != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: isFilteredView
          ? AppBar(
              title: Text(
                title ?? 'Properties',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: AppColors.primaryNavy,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: FutureBuilder<List<PropertyModel>>(
        future: isFilteredView
            ? Future.value(properties)
            : _fetchAllProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryNavy),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return _buildEmptyState(theme, isDark);
          }

          final list = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) =>
                _buildProjectCard(context, list[index], isDark),
          );
        },
      ),
    );
  }

  Future<List<PropertyModel>> _fetchAllProperties() async {
    try {
      return await PropertyService.fetchProperties();
    } catch (e) {
      return [];
    }
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.house_siding_rounded,
            size: 80,
            color: isDark
                ? Colors.white24
                : AppColors.primaryNavy.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "No properties found.",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    PropertyModel property,
    bool isDark,
  ) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(propertyId: property.id),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with Status Badge
                Stack(
                  children: [
                    Image.network(
                      property.images.isNotEmpty ? property.images[0] : '',
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 230,
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property.status.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accentYellow,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Info Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              property.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          if (property.isFeatured == 1)
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.accentYellow,
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.accentYellow,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, thickness: 0.5),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.startingFrom,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              Text(
                                "PKR ${property.price}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.accentYellow
                                      : AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProjectDetailsScreen(
                                  propertyId: property.id,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentYellow,
                              foregroundColor: AppColors.primaryNavy,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              loc.viewDetails,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
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
