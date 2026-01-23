import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/services/FavoriteService.dart';
import 'package:mera_ashiana/services/auth/login_service.dart';

class AppColors {
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color white = Colors.white;
  static const Color textGrey = Color(0xFF757575);
}

class ProjectDetailsScreen extends StatefulWidget {
  final int? propertyId;

  const ProjectDetailsScreen({super.key, this.propertyId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // Swipe Logic Variables
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool isLoading = true;
  bool hasError = false;
  bool isToggling = false;
  PropertyModel? property;

  @override
  void initState() {
    super.initState();
    fetchPropertyDetails();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Always dispose controllers
    super.dispose();
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
    HapticFeedback.mediumImpact();
    final wasLiked = FavoriteService.favoriteIds.value.contains(property!.id);
    setState(() => isToggling = true);

    try {
      await FavoriteService.toggleFavorite(
        property!.id,
        wasLiked,
        propertyData: property,
      );
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
        ),
      );
    if (hasError || property == null)
      return const Scaffold(body: Center(child: Text("Error loading data")));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(property!.images),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(isDark),
                      const SizedBox(height: 24),
                      _buildQuickSpecs(isDark),
                      const SizedBox(height: 32),
                      Text(
                        "About this property",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        property!.description,
                        style: TextStyle(
                          height: 1.6,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomAction(isDark),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(List<String> images) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryNavy,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          child: const BackButton(color: Colors.white),
        ),
      ),
      actions: [
        ValueListenableBuilder<Set<int>>(
          valueListenable: FavoriteService.favoriteIds,
          builder: (context, favSet, _) {
            final isLiked = favSet.contains(property!.id);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: isToggling ? null : _handleFavoriteToggle,
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // FIXED: RESTORED SWIPE LOGIC
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: images.length,
              itemBuilder: (context, i) {
                return Image.network(
                  images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            // Gradient for better text/icon visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent, Colors.black87],
                ),
              ),
            ),
            // FIXED: ADDED DOT INDICATORS
            if (images.length > 1)
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.accentYellow
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            property!.status.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accentYellow,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          property!.title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.accentYellow,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              property!.location,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "PKR ${property!.price}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.accentYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSpecs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _specItem(
            Icons.king_bed_rounded,
            "${property!.bedrooms}",
            "Beds",
            isDark,
          ),
          _buildVerticalDivider(isDark),
          _specItem(
            Icons.bathtub_rounded,
            "${property!.bathrooms}",
            "Baths",
            isDark,
          ),
          _buildVerticalDivider(isDark),
          _specItem(Icons.square_foot_rounded, property!.area, "Area", isDark),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentYellow, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.primaryNavy,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) => Container(
    height: 40,
    width: 1,
    color: isDark ? Colors.white10 : Colors.black12,
  );

  Widget _buildBottomAction(bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone_rounded),
                label: const Text(
                  "CONTACT AGENT",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
