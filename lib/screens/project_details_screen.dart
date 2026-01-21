import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/models/property_model.dart';
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
  PropertyModel? property;

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
        final data = widget.propertyId != null
            ? decoded['data']
            : (decoded['data'] as List).first;

        setState(() {
          property = PropertyModel.fromJson(data);

          // Sync backend "is_liked" status with our global Flutter state
          if (data['is_liked'] == true) {
            final currentSet = Set<int>.from(FavoriteService.favoriteIds.value);
            currentSet.add(property!.id);
            FavoriteService.favoritesMap[property!.id] = property!;
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

    final wasLiked = FavoriteService.favoriteIds.value.contains(property!.id);
    setState(() => isToggling = true);

    try {
      final success = await FavoriteService.toggleFavorite(
        property!.id,
        wasLiked,
        propertyData: property,
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update favorite")),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (hasError || property == null)
      return const Scaffold(body: Center(child: Text("Error loading data")));

    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(property!.images),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(theme),
                  const SizedBox(height: 10),
                  Text(
                    property!.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    property!.location,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "PKR ${property!.price}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildQuickSpecs(),
                  const SizedBox(height: 25),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property!.description,
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Chip(
          label: Text(property!.status.toUpperCase()),
          backgroundColor: theme.primaryColor.withOpacity(0.1),
        ),
        ValueListenableBuilder<Set<int>>(
          valueListenable: FavoriteService.favoriteIds,
          builder: (context, favSet, _) {
            final isLiked = favSet.contains(property!.id);
            return IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : theme.primaryColor,
                size: 30,
              ),
              onPressed: isToggling ? null : _handleFavoriteToggle,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(List<String> images) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, i) =>
              Image.network(images[i], fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildQuickSpecs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _specItem(Icons.king_bed_outlined, "${property!.bedrooms} Beds"),
        _specItem(Icons.bathtub_outlined, "${property!.bathrooms} Baths"),
        _specItem(Icons.square_foot, property!.area),
      ],
    );
  }

  Widget _specItem(IconData icon, String label) =>
      Column(children: [Icon(icon), Text(label)]);
}
