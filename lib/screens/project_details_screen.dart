import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/services/FavoriteService.dart';
import 'package:mera_ashiana/services/login_service.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int? propertyId;

  const ProjectDetailsScreen({super.key, this.propertyId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool isLoading = true;
  bool hasError = false;
  bool isToggling = false;
  Map<String, dynamic>? property;

  @override
  void initState() {
    super.initState();
    fetchPropertyDetails();
  }

  Future<void> fetchPropertyDetails() async {
    try {
      final cookie = await LoginService.getAuthCookie();
      final url = widget.propertyId != null
          ? "http://api.staging.mera-ashiana.com/api/properties/${widget.propertyId}"
          : "http://api.staging.mera-ashiana.com/api/properties?recent=true";

      final response = await http.get(
        Uri.parse(url),
        headers: {'Cookie': cookie ?? '', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          property = widget.propertyId != null
              ? decoded['data']
              : (decoded['data'] as List).first;

          if (property != null) {
            final id = property!['id'];
            final isLikedByApi = property!['is_liked'] == true;

            // SYNC GLOBAL STATE
            final currentSet = Set<int>.from(FavoriteService.favoriteIds.value);
            if (isLikedByApi) {
              currentSet.add(id);
              FavoriteService.favoritesMap[id] = property!;
            } else {
              currentSet.remove(id);
            }
            // Assigning a NEW Set instance triggers the ValueListenableBuilder
            FavoriteService.favoriteIds.value = currentSet;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _handleFavoriteToggle() async {
    if (isToggling || property == null) return;

    final propertyId = property!['id'];
    // Check current local state
    final wasLiked = FavoriteService.favoriteIds.value.contains(propertyId);

    setState(() => isToggling = true);

    try {
      // 1. If we are liking, cache the data for the Favorites screen immediately
      if (!wasLiked) {
        FavoriteService.favoritesMap[propertyId] = property!;
      }

      // 2. Call the API
      final success = await FavoriteService.toggleFavorite(
        propertyId,
        wasLiked,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !wasLiked ? "Added to Favorites" : "Removed from Favorites",
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (!success) {
        // Rollback map if API failed
        if (!wasLiked) FavoriteService.favoritesMap.remove(propertyId);
        throw Exception("Failed to update favorite status");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || property == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load property details")),
      );
    }

    final cs = theme.colorScheme;
    final images = (property!['images'] as List? ?? [])
        .map((e) => "http://api.staging.mera-ashiana.com$e")
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, images),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(theme, property!),
                  const SizedBox(height: 20),
                  _buildQuickSpecsBox(theme, property!),
                  const SizedBox(height: 20),
                  _buildSectionTitle(theme, "Description"),
                  Text(
                    property!['description'] ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if ((property!['amenities'] as List?)?.isNotEmpty ?? false)
                    _buildSectionTitle(theme, "Amenities"),
                  if ((property!['amenities'] as List?)?.isNotEmpty ?? false)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: (property!['amenities'] as List)
                          .map((e) => Chip(label: Text(e.toString())))
                          .toList(),
                    ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, Map<String, dynamic> property) {
    final cs = theme.colorScheme;
    final propertyId = property['id'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (property['status'] ?? "sale").toString().toUpperCase(),
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            // REFRESHES AUTOMATICALLY ON CHANGE
            ValueListenableBuilder<Set<int>>(
              valueListenable: FavoriteService.favoriteIds,
              builder: (context, favSet, _) {
                final liked = favSet.contains(propertyId);
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: isToggling ? null : _handleFavoriteToggle,
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : cs.primary,
                    size: 32,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          property['title'] ?? "",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: cs.onSurface.withOpacity(0.5),
            ),
            Text(
              " ${property['location'] ?? ""}",
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "PKR ${property['price'] ?? "-"}",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  // ... (Other helper methods remain the same)
  Widget _buildSliverAppBar(ThemeData theme, List<String> images) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: images.isNotEmpty
            ? PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) =>
                    Image.network(images[index], fit: BoxFit.cover),
              )
            : const Center(
                child: Icon(Icons.image, size: 50, color: Colors.white54),
              ),
      ),
    );
  }

  Widget _buildQuickSpecsBox(ThemeData theme, Map<String, dynamic> property) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _specItem(
            theme,
            Icons.king_bed_outlined,
            "${property['bedrooms'] ?? '-'}",
            "Beds",
          ),
          _divider(theme),
          _specItem(
            theme,
            Icons.bathtub_outlined,
            "${property['bathrooms'] ?? '-'}",
            "Baths",
          ),
          _divider(theme),
          _specItem(
            theme,
            Icons.square_foot,
            "${property['area'] ?? '-'}",
            "Sq. Ft",
          ),
        ],
      ),
    );
  }

  Widget _specItem(ThemeData theme, IconData icon, String value, String unit) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _divider(ThemeData theme) => Container(
    height: 35,
    width: 1,
    color: theme.dividerColor.withOpacity(0.2),
  );

  Widget _buildSectionTitle(ThemeData theme, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
