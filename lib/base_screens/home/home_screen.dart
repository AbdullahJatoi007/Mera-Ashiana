import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mera_ashiana/base_screens/properties_screen.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/services/property_service.dart';
import 'package:mera_ashiana/screens/home/home_top_section.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';
import 'package:mera_ashiana/base_screens/widgets/category_list.dart';
import 'package:mera_ashiana/base_screens/widgets/recently_added_horizontal.dart';
import 'package:mera_ashiana/base_screens/widgets/property_list_item.dart';
import 'package:mera_ashiana/base_screens/widgets/featured_card.dart';

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

  List<Listing> _listings = [];

  // Names match the listings_type enum in your Prisma schema
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'House', 'icon': Icons.home_rounded},
    {'name': 'Apartment', 'icon': Icons.apartment_rounded},
    {'name': 'Plot', 'icon': Icons.landscape_rounded},
    {'name': 'Commercial', 'icon': Icons.storefront_rounded},
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

  List<Listing> get _filteredListings {
    List<Listing> baseFiltered = _listings.where((l) {
      // Logic to match 'sale' or 'rent' enum from DB
      String status = _selectedOption == 'BUY' ? 'sale' : 'rent';
      return l.status.toLowerCase() == status;
    }).toList();

    if (_selectedCategoryIndex == 0) return baseFiltered;

    String categoryName = _categories[_selectedCategoryIndex]['name'] as String;
    return baseFiltered.where((l) {
      return l.type.toLowerCase() == categoryName.toLowerCase();
    }).toList();
  }

  Future<void> _fetchProperties({bool isRefresh = false}) async {
    if (!isRefresh) setState(() => _isLoading = true);
    try {
      final listings = await PropertyService.fetchProperties();
      if (mounted) {
        setState(() {
          _listings = listings;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('HomeScreen error: $e');
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
    final isDark = theme.brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double maxSnapOffset = 110.0;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: isDark ? AppDarkColors.errorRed : AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              const Text(
                "Unable to load properties.\nPlease check your connection.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _fetchProperties(),
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accentYellow,
        onRefresh: () async => await _fetchProperties(isRefresh: true),
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
              SliverToBoxAdapter(
                child: CategoryList(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onSelected: (index) =>
                      setState(() => _selectedCategoryIndex = index),
                ),
              ),
              // Featured Section - Updated for Boolean logic
              SliverToBoxAdapter(
                child: _buildSectionTitle(theme, loc.exploreProjects, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertiesScreen(
                        listings: _listings
                            .where((l) => l.isFeatured)
                            .toList(),
                        title: loc.exploreProjects,
                      ),
                    ),
                  );
                }),
              ),
              SliverToBoxAdapter(
                child: FeaturedProjects(
                  listings: _listings.where((l) => l.isFeatured).toList(),
                  theme: theme,
                ),
              ),
              // Recently Added
              SliverToBoxAdapter(
                child: _buildSectionTitle(theme, "Recently Added", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertiesScreen(
                        listings: _listings,
                        title: "Recently Added",
                      ),
                    ),
                  );
                }),
              ),
              SliverToBoxAdapter(
                child: RecentlyAddedHorizontal(
                  listings: _listings,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              // Main List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 12, 10),
                  child: Text(
                    "${_categories[_selectedCategoryIndex]['name']} Listings",
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
                        (context, index) => PropertyListItem(
                      listing: _filteredListings[index],
                      theme: theme,
                      isDark: isDark,
                    ),
                    childCount: _filteredListings.length,
                  ),
                ),
              ),
            ],
          ),
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