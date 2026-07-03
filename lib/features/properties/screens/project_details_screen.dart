import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/core/network/api_client.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/data/services/FavoriteService.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/utils/currency_formatter.dart';

class ProjectDetailsScreen extends StatefulWidget {
  // 🔧 Backend detail route is keyed by SLUG (`GET /listings/:slug`),
  // not by numeric id. Pass a slug, or the full Listing object.
  final String? slug;
  final Listing? listing;

  const ProjectDetailsScreen({super.key, this.slug, this.listing});

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

  // The slug to fetch full details with — from the explicit slug param,
  // or falling back to the slug on a passed-in Listing.
  String? get _effectiveSlug {
    final s = widget.slug;
    if (s != null && s.isNotEmpty) return s;
    final ls = widget.listing?.slug;
    if (ls != null && ls.isNotEmpty) return ls;
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) {
      // Paint instantly from the list object so there's no spinner...
      listing = widget.listing;
      isLoading = false;
      // ...but the LIST endpoint omits the `users` relation, so the passed
      // object has no "Listed By" name. Enrich from the detail endpoint
      // in the background (no spinner) to match the website.
      if (_effectiveSlug != null) {
        fetchPropertyDetails(showSpinner: false);
      }
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

  // ==================== Logic Methods ====================

  Future<void> fetchPropertyDetails({bool showSpinner = true}) async {
    if (showSpinner && !isLoading) setState(() => isLoading = true);
    try {
      // Request by slug. The detail endpoint looks listings up by slug,
      // so sending a numeric id resulted in a 404 ("Listing not found.").
      final slug = _effectiveSlug;
      final String path = slug != null
          ? "${Endpoints.listings}/$slug"
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
        // If we already have a placeholder from the list, keep showing it
        // instead of throwing the user to an error screen.
        if (listing == null) hasError = true;
        isLoading = false;
      });
    }
  }

  void _contactAgentCall() async {
    final phone = listing?.contactPhone ?? "";
    if (phone.isEmpty) return;

    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _contactAgentWhatsApp() async {
    final whatsapp = listing?.contactWhatsapp ?? "";
    if (whatsapp.isEmpty) return;

    // Clean the string (remove spaces/dashes) for a valid WhatsApp link
    final cleanWhatsapp = whatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse("https://wa.me/$cleanWhatsapp");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _contactAgentEmail() async {
    final email = listing?.contactEmail ?? "";
    if (email.isEmpty) return;

    final uri = Uri.parse("mailto:$email");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _handleFavoriteToggle() async {
    if (isToggling || listing == null) return;
    HapticFeedback.mediumImpact();
    setState(() => isToggling = true);
    try {
      await FavoriteService.toggleFavorite(listing!.id, listingData: listing);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't update favorite. Please check your connection.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isToggling = false);
    }
  }

  // ==================== UI Widgets ====================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
        ),
      );
    }
    if (hasError || listing == null) {
      return Scaffold(
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

  Widget _contactChip(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        if (label == "Call")
          _contactAgentCall();
        else if (label == "WhatsApp")
          _contactAgentWhatsApp();
        else if (label == "Email")
          _contactAgentEmail();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard(Listing p, bool isDark) {
    final name = p.createdByName ?? "Unknown Owner";

    // 🔧 FIX: gate the contact section on the fields the chips actually use
    // (contact_*), not on createdByPhone/Email which are absent in list data.
    final hasContact =
        (p.contactPhone?.isNotEmpty ?? false) ||
        (p.contactWhatsapp?.isNotEmpty ?? false) ||
        (p.contactEmail?.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryNavy,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Listed By",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      p.createdByType == "agency" ? "Agency" : "Verified User",
                      style: const TextStyle(
                        color: AppColors.accentYellow,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasContact)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (p.contactPhone != null && p.contactPhone!.isNotEmpty)
                  _contactChip("Call", Icons.call, Colors.blue),

                if (p.contactWhatsapp != null && p.contactWhatsapp!.isNotEmpty)
                  _contactChip("WhatsApp", Icons.chat, Colors.green),

                if (p.contactEmail != null && p.contactEmail!.isNotEmpty)
                  _contactChip("Email", Icons.email, Colors.orange),
              ],
            ),
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
            Expanded(
              child: Text(
                p.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        // Find this section inside your _buildHeaderSection method:
        const SizedBox(height: 16),
        Text(
          CurrencyFormatter.formatPakistaniPrice(p.price), // ✨ Updated code
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
        Flexible(
          child: _infoItem(Icons.king_bed_outlined, "${p.bedrooms} Beds"),
        ),
        Flexible(
          child: _infoItem(Icons.bathtub_outlined, "${p.bathrooms} Baths"),
        ),
        Flexible(child: _infoItem(Icons.square_foot_outlined, p.area ?? "N/A")),
        Flexible(child: _infoItem(Icons.home_work_outlined, p.type)),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accentYellow, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

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
              const CircleAvatar(
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

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
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
          onPressed: _contactAgentCall, // Default to call or specialized logic
          child: const Text(
            "CONTACT AGENT",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }
}
