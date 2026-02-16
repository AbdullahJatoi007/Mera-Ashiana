import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/base_screens/properties_screen.dart';
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/services/property_service.dart';
import 'package:mera_ashiana/screens/home/home_top_section.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/theme/app_colors_dark.dart';
import 'package:mera_ashiana/base_screens/widgets/category_list.dart';
import 'package:mera_ashiana/base_screens/widgets/featured_card.dart';
import 'package:mera_ashiana/base_screens/widgets/recently_added_horizontal.dart';
import 'package:mera_ashiana/base_screens/widgets/property_list_item.dart';
import 'package:mera_ashiana/base_screens/widgets/auto_sliding_featured_card.dart';

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

  Future<void> _fetchProperties({bool isRefresh = false}) async {
    if (!isRefresh) setState(() => _isLoading = true);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                "Unable to load properties.\nPlease check your internet connection.",
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await _fetchProperties();
                },
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
        color: isDark ? AppDarkColors.accentYellow : AppColors.accentYellow,
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.white,
        displacement: 40,
        edgeOffset: statusBarHeight + 20,
        onRefresh: () async {
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

              SliverPadding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                sliver: SliverToBoxAdapter(
                  child: CategoryList(
                    categories: _categories,
                    selectedIndex: _selectedCategoryIndex,
                    onSelected: (index) =>
                        setState(() => _selectedCategoryIndex = index),
                  ),
                ),
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
              SliverToBoxAdapter(
                child: FeaturedProjects(properties: _properties, theme: theme),
              ),

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
              SliverToBoxAdapter(
                child: RecentlyAddedHorizontal(
                  properties: _properties,
                  theme: theme,
                  isDark: isDark,
                ),
              ),

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
                    (context, index) => PropertyListItem(
                      property: _filteredProperties[index],
                      theme: theme,
                      isDark: isDark,
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
