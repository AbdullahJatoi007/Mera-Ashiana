import 'package:flutter/material.dart';
import 'package:mera_ashiana/controllers/home_scroll_snap_mixin.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/data/models/property_category.dart';
import 'package:mera_ashiana/features/properties/screens/properties_screen.dart';
import 'package:mera_ashiana/features/home/widgets/home_top_section.dart';
import 'package:mera_ashiana/features/home/widgets/category_list.dart';
import 'package:mera_ashiana/features/home/widgets/section_header.dart';
import 'package:mera_ashiana/features/home/widgets/home_loading_view.dart';
import 'package:mera_ashiana/features/home/widgets/home_error_view.dart';
import 'package:mera_ashiana/features/home/widgets/recently_added_horizontal.dart';
import 'package:mera_ashiana/features/properties/widgets/property_list_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../data/services/property_service.dart';
import 'package:mera_ashiana/data/models/property_category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with HomeScrollSnapMixin {
  String _selectedOption = 'BUY';
  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFetchingMore = false;
  bool _hasMorePages = true;
  int _currentPage = 1;
  List<Listing> _listings = [];

  static const int _pageSize = 30;
  static const int _minListingsPerCategory = 20;
  static const int _maxPagesToFetch =
      6; // safety cap, avoids unbounded fetching

  final List<PropertyCategory> _categories = PropertyCategory.all;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  List<Listing> get _filteredListings {
    final String targetPurpose = _selectedOption == 'BUY' ? 'sale' : 'rent';

    final List<Listing> byPurpose = _listings
        .where((l) => (l.status ?? '').toLowerCase() == targetPurpose)
        .toList();

    final PropertyCategory selectedCategory =
        _categories[_selectedCategoryIndex];
    return byPurpose.where((l) => selectedCategory.matches(l.type)).toList();
  }

  Future<void> _fetchProperties({bool isRefresh = false}) async {
    if (!isRefresh) setState(() => _isLoading = true);
    _currentPage = 1;
    _hasMorePages = true;

    try {
      final listings = await PropertyService.fetchProperties(
        page: _currentPage,
        limit: _pageSize,
      );
      if (!mounted) return;

      setState(() {
        _listings = listings;
        _isLoading = false;
        _hasError = false;
        _hasMorePages = listings.length == _pageSize;
      });

      // Top up if the currently selected category is under-filled
      await _ensureMinimumListingsForSelectedCategory();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// Keeps fetching subsequent pages (appending to _listings) until the
  /// currently selected category has at least [_minListingsPerCategory]
  /// matches, the backend has no more pages, or the safety cap is hit.
  Future<void> _ensureMinimumListingsForSelectedCategory() async {
    if (_isFetchingMore) return;

    while (_hasMorePages &&
        _currentPage < _maxPagesToFetch &&
        _filteredListings.length < _minListingsPerCategory) {
      setState(() => _isFetchingMore = true);

      try {
        final nextPage = _currentPage + 1;
        final more = await PropertyService.fetchProperties(
          page: nextPage,
          limit: _pageSize,
        );

        if (!mounted) return;

        setState(() {
          _currentPage = nextPage;
          _listings = [..._listings, ...more];
          _hasMorePages = more.length == _pageSize;
        });
      } catch (_) {
        // Stop trying silently — whatever we already have will just be shown.
        break;
      }
    }

    if (mounted) setState(() => _isFetchingMore = false);
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);
    _ensureMinimumListingsForSelectedCategory();
  }

  void _updateSearchOption(String value) {
    if (_selectedOption == value) return;
    setState(() => _selectedOption = value);

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }

    _ensureMinimumListingsForSelectedCategory();
  }

  void _pushPropertiesScreen({
    required List<Listing> listings,
    required String title,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertiesScreen(listings: listings, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final Color scaffoldBg = isDark
        ? AppDarkColors.background
        : AppColors.background;

    if (_isLoading) return HomeLoadingView(backgroundColor: scaffoldBg);
    if (_hasError) {
      return HomeErrorView(
        backgroundColor: scaffoldBg,
        onRetry: _fetchProperties,
      );
    }

    final PropertyCategory selectedCategory =
        _categories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + 100,
            child: Container(color: scaffoldBg),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: handleScrollNotification,
            child: RefreshIndicator(
              color: AppColors.accentYellow,
              onRefresh: () => _fetchProperties(isRefresh: true),
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  HomeTopSection(
                    selectedOption: _selectedOption,
                    statusBarHeight: statusBarHeight,
                    onOptionSelected: _updateSearchOption,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CategoryList(
                        categories: _categories,
                        selectedIndex: _selectedCategoryIndex,
                        onSelected: _onCategorySelected,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Recently Added',
                      theme: theme,
                      onSeeAll: () => _pushPropertiesScreen(
                        listings: _listings,
                        title: 'Recently Added',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RecentlyAddedHorizontal(
                      listings: _listings,
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: '${selectedCategory.label} Listings',
                      theme: theme,
                      onSeeAll: () => _pushPropertiesScreen(
                        listings: _filteredListings,
                        title: '${selectedCategory.label} Properties',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 30),
                    sliver: _filteredListings.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No properties found in this category.',
                              ),
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
                  if (_isFetchingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
