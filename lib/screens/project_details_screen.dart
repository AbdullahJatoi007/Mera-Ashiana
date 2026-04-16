import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/core/api_client.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/services/FavoriteService.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int? propertyId;
  final Listing? listing;

  const ProjectDetailsScreen({
    super.key,
    this.propertyId,
    this.listing,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;

  bool isLoading = true;
  bool hasError = false;
  bool isToggling = false;

  Listing? listing;

  @override
  void initState() {
    super.initState();

    if (widget.listing != null) {
      listing = widget.listing;
      isLoading = false;
    } else {
      fetchPropertyDetails();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPropertyDetails() async {
    try {
      final String path = widget.propertyId != null
          ? "/properties/${widget.propertyId}"
          : "/properties?recent=true";

      final response = await ApiClient.get(path);

      if (response.statusCode == 200) {
        final data = widget.propertyId != null
            ? response.data['data']
            : (response.data['data'] as List).first;

        if (!mounted) return;

        setState(() {
          listing = Listing.fromJson(data);

          if (data['is_liked'] == true) {
            final set = Set<int>.from(FavoriteService.favoriteIds.value);
            set.add(listing!.id);

            FavoriteService.favoritesMap[listing!.id] = listing!;
            FavoriteService.favoriteIds.value = set;
          }

          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _handleFavoriteToggle() async {
    if (isToggling || listing == null) return;

    HapticFeedback.mediumImpact();

    final wasLiked =
    FavoriteService.favoriteIds.value.contains(listing!.id);

    setState(() => isToggling = true);

    try {
      // ✅ FIXED: ONLY ONE positional argument allowed
      await FavoriteService.toggleFavorite(
        listing!.id,
        listingData: listing,
      );
    } finally {
      if (mounted) setState(() => isToggling = false);
    }
  }

  void _contactAgent() async {
    if (listing == null) return;

    final whatsapp = listing!.contactWhatsapp ?? "";
    final phone = listing!.contactPhone ?? "";

    if (whatsapp.isNotEmpty) {
      final uri = Uri.parse("https://wa.me/$whatsapp");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (phone.isNotEmpty) {
      final uri = Uri.parse("tel:$phone");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accentYellow,
          ),
        ),
      );
    }

    if (hasError || listing == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(
          child: ElevatedButton(
            onPressed: fetchPropertyDetails,
            child: const Text("Retry"),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final property = listing!;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildImageGallery(property.images),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(isDark),
                      const SizedBox(height: 24),
                      _buildQuickSpecs(isDark),
                      const SizedBox(height: 32),
                      const Text(
                        "About this property",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(property.description),
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFloatingHeader(),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: images.length,
        itemBuilder: (_, i) =>
            Image.network(images[i], fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BackButton(color: Colors.white),
            ValueListenableBuilder<Set<int>>(
              valueListenable: FavoriteService.favoriteIds,
              builder: (_, favs, __) {
                final liked = favs.contains(listing!.id);

                return IconButton(
                  icon: Icon(
                    liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: _handleFavoriteToggle,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(listing!.status.toUpperCase()),
        const SizedBox(height: 10),
        Text(listing!.title),
        Text(listing!.location),
        Text("PKR ${listing!.price}"),
      ],
    );
  }

  Widget _buildQuickSpecs(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("${listing!.bedrooms} Beds"),
        Text("${listing!.bathrooms} Baths"),
        Text(listing!.area ?? ""),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _contactAgent,
          child: const Text("CONTACT AGENT"),
        ),
      ),
    );
  }
}