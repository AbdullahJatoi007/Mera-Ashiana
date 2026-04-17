import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/core/api_client.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/services/FavoriteService.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/endpoints.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int? propertyId;
  final Listing? listing;

  const ProjectDetailsScreen({super.key, this.propertyId, this.listing});

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
          ? Endpoints.listing(widget.propertyId!)
          : "${Endpoints.listings}?recent=true";

      final response = await ApiClient.get(path);
      final dynamic rawData =
          (response.data is Map && response.data.containsKey('data'))
          ? response.data['data']
          : response.data;

      Map<String, dynamic>? listingMap;
      if (rawData is List && rawData.isNotEmpty) {
        listingMap = rawData.first as Map<String, dynamic>;
      } else if (rawData is Map<String, dynamic>) {
        listingMap = rawData;
      }

      if (listingMap == null) throw Exception("No data found");

      if (!mounted) return;
      setState(() {
        listing = Listing.fromJson(listingMap!);
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
        ),
      );
    if (hasError || listing == null)
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: fetchPropertyDetails,
            child: const Text("Retry"),
          ),
        ),
      );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final property = listing!;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(property.images),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(property, isDark),
                      const SizedBox(height: 24),
                      _buildPropertySummary(property, isDark),
                      const Divider(height: 48),
                      const Text(
                        "About this property",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        property.description,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildAgentCard(property, isDark),
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

  Widget _buildHeaderSection(Listing p, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentYellow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            p.status.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          p.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppColors.accentYellow,
            ),
            const SizedBox(width: 4),
            Text(
              p.location,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "PKR ${p.price.toStringAsFixed(0)}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.accentYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertySummary(Listing p, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Wrapping each in Expanded prevents the "20 pixels overflow" error
        Expanded(child: _infoItem(Icons.king_bed_outlined, "${p.bedrooms} Beds")),
        Expanded(child: _infoItem(Icons.bathtub_outlined, "${p.bathrooms} Baths")),
        Expanded(child: _infoItem(Icons.square_foot_outlined, p.area ?? "N/A")),
        Expanded(child: _infoItem(Icons.home_work_outlined, p.type)),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentYellow),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAgentCard(Listing p, bool isDark) {
    // Use the name from the model, falling back to a default if null
    final String agentName = p.createdBy ?? "Mera Ashiana Agent";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryNavy,
            child: Text(
              agentName[0].toUpperCase(), // Shows first letter of Agent Name
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Listed By",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  agentName, // ✅ Dynamic name (e.g., Vijay Malhi)
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  "Verified User", // Or "Verified Agency"
                  style: TextStyle(color: AppColors.accentYellow, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gallery and Action widgets stay similar but with cleaner styling
  Widget _buildImageGallery(List<String> images) {
    return Stack(
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => Image.network(images[i], fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_currentPage + 1}/${images.length}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _contactAgent,
          child: const Text(
            "CONTACT AGENT",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }

  // Floating Header with Back Button and Fav
  Widget _buildFloatingHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black26,
                child: BackButton(color: Colors.white),
              ),
              ValueListenableBuilder<Set<int>>(
                valueListenable: FavoriteService.favoriteIds,
                builder: (_, favs, __) {
                  final liked = favs.contains(listing!.id);
                  return CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : Colors.white,
                      ),
                      onPressed: _handleFavoriteToggle,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFavoriteToggle() async {
    if (isToggling || listing == null) return;

    HapticFeedback.mediumImpact();

    setState(() => isToggling = true);

    try {
      await FavoriteService.toggleFavorite(listing!.id, listingData: listing);
    } finally {
      if (mounted) {
        setState(() => isToggling = false);
      }
    }
  }

  void _contactAgent() async {
    if (listing == null) return;
    final whatsapp = listing!.contactWhatsapp ?? "";
    final phone = listing!.contactPhone ?? "";
    if (whatsapp.isNotEmpty) {
      final uri = Uri.parse("https://wa.me/$whatsapp");
      if (await canLaunchUrl(uri))
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (phone.isNotEmpty) {
      final uri = Uri.parse("tel:$phone");
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  }
}
