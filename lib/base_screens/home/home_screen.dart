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
  String _selectedOption = 'BUY'; // Matches 'sale' in API
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _hasError = false;
  List<Listing> _listings = [];

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

  // --- UI Logic & Filtering ---

  List<Listing> get _filteredListings {
    // 1. Filter by Purpose (Matching website: /properties?purpose=rent or sale)
    List<Listing> baseFiltered = _listings.where((l) {
      String targetPurpose = _selectedOption == 'BUY' ? 'sale' : 'rent';
      // Lowercase comparison prevents string mismatch errors
      return (l.status ?? '').toLowerCase() == targetPurpose;
    }).toList();

    // 2. Filter by Category
    if (_selectedCategoryIndex == 0) return baseFiltered;

    String categoryName = _categories[_selectedCategoryIndex]['name'] as String;
    return baseFiltered.where((l) {
      return (l.type ?? '').toLowerCase() == categoryName.toLowerCase();
    }).toList();
  }

  void _updateSearchOption(String value) {
    if (_selectedOption == value) return;
    setState(() => _selectedOption = value);

    // Smooth scroll to top when changing filters
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppDarkColors.background
            : AppColors.background,
        body: const Center(
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
              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Check your connection and try again",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                ),
                onPressed: () => _fetchProperties(),
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.black),
                ),
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
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Top Section with Buy/Rent Toggle
            HomeTopSection(
              selectedOption: _selectedOption,
              statusBarHeight: statusBarHeight,
              onOptionSelected: _updateSearchOption,
            ),

            // Horizontal Category Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CategoryList(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onSelected: (index) =>
                      setState(() => _selectedCategoryIndex = index),
                ),
              ),
            ),

            // Recently Added Section (Top Priority)
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

            // Main Listings Header
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                theme,
                "${_categories[_selectedCategoryIndex]['name']} Listings",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertiesScreen(
                        listings: _filteredListings,
                        title:
                            "${_categories[_selectedCategoryIndex]['name']} Properties",
                      ),
                    ),
                  );
                },
              ),
            ),

            // The Vertical List
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 30),
              sliver: _filteredListings.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("No properties found in this category."),
                      ),
                    )
                  : SliverList(
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
    );
  }

  // Polished Section Header Helper
  Widget _buildSectionTitle(
    ThemeData theme,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: Row(
              children: [
                Text(
                  "See All",
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
