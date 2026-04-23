import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Added for ScrollDirection
import 'package:mera_ashiana/base_screens/properties_screen.dart';
import 'package:mera_ashiana/models/listing_model.dart';
import 'package:mera_ashiana/services/property_service.dart';
import 'package:mera_ashiana/screens/home/home_top_section.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';
import 'package:mera_ashiana/base_screens/widgets/category_list.dart';
import 'package:mera_ashiana/base_screens/widgets/recently_added_horizontal.dart';
import 'package:mera_ashiana/base_screens/widgets/property_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State ────────────────────────────────────────────────────────────────────
  String _selectedOption = 'BUY';
  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  List<Listing> _listings = [];

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'House', 'icon': Icons.home_rounded},
    {'name': 'Apartment', 'icon': Icons.apartment_rounded},
    {'name': 'Plot', 'icon': Icons.landscape_rounded},
    {'name': 'Commercial', 'icon': Icons.storefront_rounded},
  ];

  // The full collapsible range of the header (content height only, not status bar)
  double get _snapRange => 95.0;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
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

  // ── Snap Logic ───────────────────────────────────────────────────────────────
  void _handleSnap() {
    if (!_scrollController.hasClients) return;

    // Use a slight delay so we don't fight Flutter's internal scroll momentum physics
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || !_scrollController.hasClients) return;

      final double offset = _scrollController.offset;

      // Already at a settled position — nothing to do
      if (offset <= 0.0 || offset >= _snapRange) return;

      // Snap to whichever extreme is closer
      final double target = offset > (_snapRange / 2.0) ? _snapRange : 0.0;

      // Ensure we aren't already animating
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // ── Filtering ────────────────────────────────────────────────────────────────
  List<Listing> get _filteredListings {
    final String targetPurpose = _selectedOption == 'BUY' ? 'sale' : 'rent';

    final List<Listing> byPurpose = _listings
        .where((l) => (l.status ?? '').toLowerCase() == targetPurpose)
        .toList();

    if (_selectedCategoryIndex == 0) return byPurpose;

    final String categoryName =
        _categories[_selectedCategoryIndex]['name'] as String;

    return byPurpose
        .where(
          (l) => (l.type ?? '').toLowerCase() == categoryName.toLowerCase(),
        )
        .toList();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  void _updateSearchOption(String value) {
    if (_selectedOption == value) return;
    setState(() => _selectedOption = value);

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
      if (!mounted) return;
      setState(() {
        _listings = listings;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final Color scaffoldBg = isDark
        ? AppDarkColors.background
        : AppColors.background;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentYellow),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        // ... (Error UI remains unchanged)
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Check your connection and try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _fetchProperties,
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Navy blue background fix for iOS/Android overscroll bouncing
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + 100,
            child: Container(color: HomeTopSection.primaryNavy),
          ),

          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              // Trigger snap when scrolling comes to a complete stop
              if (notification is ScrollEndNotification) {
                _handleSnap();
              }
              // Trigger snap when user lifts their finger (idle direction)
              else if (notification is UserScrollNotification &&
                  notification.direction == ScrollDirection.idle) {
                _handleSnap();
              }
              return false; // Allow events to bubble up to RefreshIndicator
            },
            child: RefreshIndicator(
              color: AppColors.accentYellow,
              onRefresh: () => _fetchProperties(isRefresh: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  HomeTopSection(
                    selectedOption: _selectedOption,
                    statusBarHeight: statusBarHeight,
                    onOptionSelected: _updateSearchOption,
                  ),

                  // Category chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CategoryList(
                        categories: _categories,
                        selectedIndex: _selectedCategoryIndex,
                        onSelected: (index) =>
                            setState(() => _selectedCategoryIndex = index),
                      ),
                    ),
                  ),

                  // Recently Added
                  SliverToBoxAdapter(
                    child: _SectionHeader(
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

                  // Listings header
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title:
                          '${_categories[_selectedCategoryIndex]['name']} Listings',
                      theme: theme,
                      onSeeAll: () => _pushPropertiesScreen(
                        listings: _filteredListings,
                        title:
                            '${_categories[_selectedCategoryIndex]['name']} Properties',
                      ),
                    ),
                  ),

                  // Vertical property list
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.theme,
    required this.onSeeAll,
  });

  final String title;
  final ThemeData theme;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 10),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
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
