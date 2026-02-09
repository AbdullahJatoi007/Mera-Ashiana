import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/services/property_service.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/helpers/internet_helper.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';

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
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
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
              backgroundColor: isDark
                  ? AppDarkColors.primaryNavy
                  : AppColors.primaryNavy,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: FutureBuilder<List<PropertyModel>>(
        future: _fetchProperties(isFilteredView),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark
                    ? AppDarkColors.primaryNavy
                    : AppColors.primaryNavy,
              ),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark, context);
          }

          final list = snapshot.data!;

          return RefreshIndicator(
            color: isDark ? AppDarkColors.accentYellow : AppColors.accentYellow,
            onRefresh: () async {
              bool connected = await InternetHelper.hasInternetConnection();
              if (connected) {
                (context as Element).reassemble();
              } else {
                _showNoInternetDialog(context);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) =>
                  _buildProjectCard(context, list[index], isDark),
            ),
          );
        },
      ),
    );
  }

  Future<List<PropertyModel>> _fetchProperties(bool isFilteredView) async {
    bool connected = await InternetHelper.hasInternetConnection();
    if (!connected) return [];
    return isFilteredView
        ? Future.value(properties)
        : PropertyService.fetchProperties();
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("No Internet Connection"),
        content: const Text(
          "Please check your internet connection and try again.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.house_siding_rounded,
            size: 80,
            color: isDark
                ? AppDarkColors.textSecondary
                : AppColors.primaryNavy.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "No properties found.",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppDarkColors.textSecondary : AppColors.textGrey,
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
        color: isDark ? AppDarkColors.surface : AppColors.white,
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
                Stack(
                  children: [
                    Image.network(
                      property.images.isNotEmpty ? property.images[0] : '',
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 230,
                        color: isDark
                            ? AppDarkColors.surface
                            : Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          color: isDark
                              ? AppDarkColors.textSecondary
                              : AppColors.textGrey,
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
                          color:
                              (isDark
                                      ? AppDarkColors.primaryNavy
                                      : AppColors.primaryNavy)
                                  .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property.status.toUpperCase(),
                          style: TextStyle(
                            color: isDark
                                ? AppDarkColors.accentYellow
                                : AppColors.accentYellow,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                            child: Text(
                              property.title,
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
                          if (property.isFeatured == 1)
                            Icon(
                              Icons.verified_rounded,
                              color: isDark
                                  ? AppDarkColors.accentYellow
                                  : AppColors.accentYellow,
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: isDark
                                ? AppDarkColors.accentYellow
                                : AppColors.accentYellow,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              style: TextStyle(
                                color: isDark
                                    ? AppDarkColors.textSecondary
                                    : AppColors.textGrey,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
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
