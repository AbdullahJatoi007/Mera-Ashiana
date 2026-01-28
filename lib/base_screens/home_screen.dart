import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'; // Added for Haptic Feedback
import 'package:mera_ashiana/base_screens/properties_screen.dart';
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/services/property_service.dart';
import 'package:mera_ashiana/screens/home/home_top_section.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedOption = 'BUY';
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _hasError = false;
  List<PropertyModel> _properties = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'House', 'icon': Icons.home_rounded},
    {'name': 'Flat', 'icon': Icons.apartment_rounded},
    {'name': 'Plot', 'icon': Icons.landscape_rounded},
    {'name': 'Shop', 'icon': Icons.storefront_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<PropertyModel> get _filteredProperties {
    if (_selectedCategoryIndex == 0) return _properties;
    String categoryName = _categories[_selectedCategoryIndex]['name'] as String;
    return _properties
        .where((p) => p.status.toLowerCase() == categoryName.toLowerCase())
        .toList();
  }

  /// Fetches properties from the service.
  /// [isRefresh] determines if we show the full-screen loader or a silent update.
  Future<void> _fetchProperties({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final properties = await PropertyService.fetchProperties();
      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _handleSnap(double maxSnapOffset) {
    if (!_scrollController.hasClients) return;
    double currentOffset = _scrollController.offset;
    if (currentOffset > 0 && currentOffset < maxSnapOffset) {
      double target = (currentOffset < maxSnapOffset / 2) ? 0 : maxSnapOffset;
      Future.microtask(() {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double maxSnapOffset = 110.0;

    // Loading State
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Error State with Retry Best Practice
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text("Failed to load properties"),
              TextButton(
                onPressed: () => _fetchProperties(),
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        // Google Best Practice: Use theme colors and position correctly
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        displacement: 40,
        edgeOffset: statusBarHeight + 20,
        onRefresh: () async {
          // Play Console Best Practice: Provide haptic feedback on manual refresh
          HapticFeedback.mediumImpact();
          await _fetchProperties(isRefresh: true);
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is UserScrollNotification &&
                notification.direction == ScrollDirection.idle) {
              _handleSnap(maxSnapOffset);
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            // Use AlwaysScrollableScrollPhysics so swipe-to-refresh works even on short lists
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              HomeTopSection(
                selectedOption: _selectedOption,
                statusBarHeight: statusBarHeight,
                onOptionSelected: (value) =>
                    setState(() => _selectedOption = value),
              ),

              // Category Selector
              SliverPadding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                sliver: SliverToBoxAdapter(child: _buildCategoryList(theme)),
              ),

              // 1. FEATURED SECTION
              SliverToBoxAdapter(
                child: _buildSectionTitle(theme, loc.exploreProjects, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertiesScreen(
                        properties: _properties
                            .where((p) => p.isFeatured == 1)
                            .toList(),
                        title: loc.exploreProjects,
                      ),
                    ),
                  );
                }),
              ),
              SliverToBoxAdapter(child: _buildFeaturedProjects(theme)),

              // 2. RECENTLY ADDED SECTION
              SliverToBoxAdapter(
                child: _buildSectionTitle(theme, "Recently Added", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertiesScreen(
                        properties: _properties,
                        title: "Recently Added",
                      ),
                    ),
                  );
                }),
              ),
              SliverToBoxAdapter(child: _buildRecentlyAddedHorizontal(theme)),

              // 3. FILTERED LIST SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 12, 10),
                  child: Text(
                    "All ${_categories[_selectedCategoryIndex]['name']} Listings",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPropertyListItem(
                      theme,
                      _filteredProperties[index],
                    ),
                    childCount: _filteredProperties.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets Below ---

  Widget _buildCategoryList(ThemeData theme) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              showCheckmark: false,
              label: Text(_categories[index]['name'] as String),
              avatar: Icon(
                _categories[index]['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              selected: isSelected,
              onSelected: (bool selected) =>
                  setState(() => _selectedCategoryIndex = index),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProjects(ThemeData theme) {
    final featured = _properties.where((p) => p.isFeatured == 1).toList();
    if (featured.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featured.length,
        itemBuilder: (context, index) =>
            AutoSlidingFeaturedCard(property: featured[index], theme: theme),
      ),
    );
  }

  Widget _buildRecentlyAddedHorizontal(ThemeData theme) {
    final recent = _properties.reversed.take(6).toList();
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final property = recent[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(propertyId: property.id),
              ),
            ),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      property.images.isNotEmpty ? property.images[0] : '',
                      height: 90,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(height: 90, color: Colors.grey[300]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "PKR ${property.price}",
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyListItem(ThemeData theme, PropertyModel property) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(propertyId: property.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'property_${property.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property.images.isNotEmpty ? property.images[0] : '',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 90, height: 90, color: Colors.grey[200]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    property.location,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "PKR ${property.price}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    ThemeData theme,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              "See All",
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// AUTO SLIDING CARD
// =============================================================================

class AutoSlidingFeaturedCard extends StatefulWidget {
  final PropertyModel property;
  final ThemeData theme;

  const AutoSlidingFeaturedCard({
    super.key,
    required this.property,
    required this.theme,
  });

  @override
  State<AutoSlidingFeaturedCard> createState() =>
      _AutoSlidingFeaturedCardState();
}

class _AutoSlidingFeaturedCardState extends State<AutoSlidingFeaturedCard> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.property.images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % widget.property.images.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.property.images.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(propertyId: widget.property.id),
        ),
      ),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: hasImages ? widget.property.images.length : 1,
                itemBuilder: (context, i) {
                  return Image.network(
                    hasImages ? widget.property.images[i] : '',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.home, size: 50),
                    ),
                  );
                },
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "PKR ${widget.property.price}",
                      style: TextStyle(
                        color: widget.theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
