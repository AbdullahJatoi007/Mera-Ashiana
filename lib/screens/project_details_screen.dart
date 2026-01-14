import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProjectDetailsScreen extends StatefulWidget {
  final int? propertyId;

  const ProjectDetailsScreen({super.key, this.propertyId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool isLoading = true;
  bool hasError = false;
  Map<String, dynamic>? property;

  @override
  void initState() {
    super.initState();
    fetchPropertyDetails();
  }

  Future<void> fetchPropertyDetails() async {
    try {
      final url = widget.propertyId != null
          ? "http://api.staging.mera-ashiana.com/api/properties/${widget.propertyId}"
          : "http://api.staging.mera-ashiana.com/api/properties?recent=true";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          property = widget.propertyId != null
              ? decoded['data']
              : (decoded['data'] as List).first;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || property == null) {
      return Scaffold(
        body: Center(child: Text("Failed to load property details")),
      );
    }

    final cs = theme.colorScheme;
    final images = (property!['images'] as List? ?? [])
        .map((e) => "http://api.staging.mera-ashiana.com$e")
        .toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          CustomScrollView(
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
                      if ((property!['amenities'] as List?)?.isNotEmpty ??
                          false)
                        _buildSectionTitle(theme, "Amenities"),
                      if ((property!['amenities'] as List?)?.isNotEmpty ??
                          false)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: (property!['amenities'] as List)
                              .map((e) => Chip(label: Text(e.toString())))
                              .toList(),
                        ),
                      const SizedBox(height: 30),
                      _buildSectionTitle(theme, "Contact Agent"),
                      Row(
                        children: [
                          if (property!['contact_phone'] != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // launch phone call
                                },
                                icon: const Icon(Icons.call),
                                label: Text(property!['contact_phone']),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          if (property!['contact_whatsapp'] != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // launch WhatsApp
                                },
                                icon: const Icon(Icons.message_outlined),
                                label: Text(property!['contact_whatsapp']),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            : const SizedBox(),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, Map<String, dynamic> property) {
    final cs = theme.colorScheme;
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
            Icon(Icons.favorite_border, color: cs.primary),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          property['title'] ?? "",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
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
          _divider(theme),
          _specItem(
            theme,
            Icons.local_parking,
            "${property['parking_size'] ?? '-'}",
            "Parking",
          ),
          _divider(theme),
          _specItem(
            theme,
            Icons.calendar_today,
            "${property['year_built'] ?? '-'}",
            "Year",
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
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

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
