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
  bool _isCategoryLoading = false;
  List<Listing> _listings = []; // general "Recently Added" / "All" feed

  static const int _minListingsPerCategory = 20;

  final List<PropertyCategory> _categories = PropertyCategory.all;

  /// Per (category, buy/rent) results fetched via server-side `type`
  /// filtering — same query shape the website uses. Keyed so switching
  /// back and forth doesn't refetch unnecessarily.
  final Map<String, List<Listing>> _categoryListingsCache = {};

  String get _cacheKey => '$_selectedCategoryIndex-$_selectedOption';

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  String get _targetStatus => _selectedOption == 'BUY' ? 'sale' : 'rent';

  List<Listing> get _filteredListings {
    if (_selectedCategoryIndex == 0) {
      // "All" — just the general feed, filtered by buy/rent
      return _listings
          .where((l) => (l.status ?? '').toLowerCase() == _targetStatus)
          .toList();
    }
    return _categoryListingsCache[_cacheKey] ?? [];
  }

  Future<void> _fetchProperties({bool isRefresh = false}) async {
    if (!isRefresh) setState(() => _isLoading = true);

    try {
      final listings = await PropertyService.fetchProperties(
        page: 1,
        limit: 30,
      );
      if (!mounted) return;
      setState(() {
        _listings = listings;
        _isLoading = false;
        _hasError = false;
      });

      if (isRefresh) _categoryListingsCache.clear();
      await _loadCategoryListingsIfNeeded();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// Fetches listings for the currently selected category directly from
  /// the API, filtered server-side by `type` (+ `status`) — one request
  /// per underlying type the category maps to, merged and de-duplicated.
  /// This mirrors exactly how the website's /properties?type=... filter
  /// works, so results match what's actually in the database instead of
  /// hoping enough matches turn up in generically-paginated results.
  Future<void> _loadCategoryListingsIfNeeded() async {
    if (_selectedCategoryIndex == 0) return; // "All" needs no extra fetch

    final key = _cacheKey;
    if (_categoryListingsCache.containsKey(key)) return; // already cached

    setState(() => _isCategoryLoading = true);

    final category = _categories[_selectedCategoryIndex];

    try {
      final results = await Future.wait(
        category.matchingTypes.map(
          (type) => PropertyService.fetchProperties(
            page: 1,
            limit: _minListingsPerCategory,
            filters: {'type': type, 'status': _targetStatus},
          ),
        ),
      );

      final merged = <int, Listing>{};
      for (final list in results) {
        for (final listing in list) {
          merged[listing.id] = listing;
        }
      }

      if (!mounted) return;
      setState(() {
        _categoryListingsCache[key] = merged.values.toList();
        _isCategoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCategoryLoading = false);
    }
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);
    _loadCategoryListingsIfNeeded();
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

    _loadCategoryListingsIfNeeded();
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
                  if (_isCategoryLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
