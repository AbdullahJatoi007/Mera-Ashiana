import 'dart:async'; // Required for Timer
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  Future<void> _fetchProperties() async {
    try {
      final properties = await PropertyService.fetchProperties();
      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
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

    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_hasError)
      return const Scaffold(
        body: Center(child: Text("Failed to load properties")),
      );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification &&
              notification.direction == ScrollDirection.idle) {
            _handleSnap(maxSnapOffset);
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            HomeTopSection(
              selectedOption: _selectedOption,
              statusBarHeight: statusBarHeight,
              onOptionSelected: (value) =>
                  setState(() => _selectedOption = value),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 15, bottom: 5),
              sliver: SliverToBoxAdapter(child: _buildCategoryList(theme)),
            ),
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
            // Featured Projects Row
            SliverToBoxAdapter(child: _buildFeaturedProjects(theme)),
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
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildPropertyListItem(theme, _filteredProperties[index]),
                  childCount: _filteredProperties.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Category Chips ---
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

  // --- Horizontal Featured List ---
  Widget _buildFeaturedProjects(ThemeData theme) {
    final featuredProperties = _properties
        .where((p) => p.isFeatured == 1)
        .toList();
    if (featuredProperties.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featuredProperties.length,
        itemBuilder: (context, index) {
          return AutoSlidingFeaturedCard(
            property: featuredProperties[index],
            theme: theme,
          );
        },
      ),
    );
  }

  // --- Vertical List Item ---
  Widget _buildPropertyListItem(ThemeData theme, PropertyModel property) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(propertyId: property.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                property.images.isNotEmpty ? property.images[0] : '',
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    property.location,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "PKR ${property.price}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.secondary,
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
      padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              "See All",
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NEW: AUTO SLIDING CARD WIDGET
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
    _pageController = PageController(initialPage: 0);

    // Setup Auto-play if there are multiple images
    if (widget.property.images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_pageController.hasClients) {
          _currentPage++;
          if (_currentPage >= widget.property.images.length) {
            _currentPage = 0;
          }
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
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(propertyId: widget.property.id),
        ),
      ),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // PageView for auto-sliding images
              PageView.builder(
                controller: _pageController,
                itemCount: widget.property.images.length,
                onPageChanged: (index) => _currentPage = index,
                physics: const NeverScrollableScrollPhysics(),
                // User shouldn't scroll images inside horizontal list
                itemBuilder: (context, i) {
                  return Image.network(
                    widget.property.images[i],
                    fit: BoxFit.cover,
                  );
                },
              ),
              // Info Overlay with Gradient
              Container(
                decoration: BoxDecoration(
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "PKR ${widget.property.price}",
                      style: TextStyle(
                        color: widget.theme.colorScheme.secondary,
                        fontSize: 11,
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
