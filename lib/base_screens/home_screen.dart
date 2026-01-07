import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSnap(double maxSnapOffset) {
    if (!_scrollController.hasClients) return;
    double currentOffset = _scrollController.offset;
    if (currentOffset > 0 && currentOffset < maxSnapOffset) {
      double target = (currentOffset < maxSnapOffset / 2) ? 0 : maxSnapOffset;
      Future.microtask(() {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context); // Access current theme
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double maxSnapOffset = 110.0;

    return Scaffold(
      // Dynamic background color from theme
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
              onOptionSelected: (value) {
                setState(() => _selectedOption = value);
              },
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
                    builder: (context) => const ProjectDetailsScreen(),
                  ),
                );
              }),
            ),
            SliverToBoxAdapter(child: _buildFeaturedProjects(theme)),
            SliverToBoxAdapter(
              child: _buildSectionTitle(theme, "Recently Added", () {}),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPropertyListItem(theme, index),
                  childCount: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(ThemeData theme) {
    final categories = [
      {'name': 'All', 'icon': Icons.grid_view_rounded},
      {'name': 'House', 'icon': Icons.home_rounded},
      {'name': 'Flat', 'icon': Icons.apartment_rounded},
      {'name': 'Plot', 'icon': Icons.landscape_rounded},
      {'name': 'Shop', 'icon': Icons.storefront_rounded},
    ];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              showCheckmark: false,
              label: Text(categories[index]['name'] as String),
              labelStyle: TextStyle(
                // Use white text if selected, otherwise theme text color
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              avatar: Icon(
                categories[index]['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() => _selectedCategoryIndex = index);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.1),
                ),
              ),
            ),
          );
        },
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
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

  Widget _buildFeaturedProjects(ThemeData theme) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 12, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://images.pexels.com/photos/323780/pexels-photo-323780.jpeg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ashiana Gold Residency",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Starting PKR 45 Lakh",
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 11,
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

  Widget _buildPropertyListItem(ThemeData theme, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg",
              width: 85,
              height: 85,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Modern 3-Bed Flat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  "Gulshan, Karachi",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "PKR 1.2 Cr",
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
    );
  }
}
