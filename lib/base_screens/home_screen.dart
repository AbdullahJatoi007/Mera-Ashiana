import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Added for ScrollDirection
import 'package:mera_ashiana/screens/home/home_top_section.dart';
import 'package:mera_ashiana/screens/project_details_screen.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedOption = 'BUY';
  int _selectedCategoryIndex = 0;

  // 1. Create the ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 2. Logic to snap the header open or closed
  void _handleSnap(double maxSnapOffset) {
    if (!_scrollController.hasClients) return;

    double currentOffset = _scrollController.offset;
    if (currentOffset > 0 && currentOffset < maxSnapOffset) {
      // If scrolled less than half, snap back to open. Otherwise, snap to closed.
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // The distance between Max (170) and Min (60) height
    const double maxSnapOffset = 110.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      // 3. Wrap with NotificationListener to catch the end of a scroll
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
              sliver: SliverToBoxAdapter(child: _buildCategoryList()),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(loc.exploreProjects, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProjectDetailsScreen()),
                );
              }),
            ),
            SliverToBoxAdapter(child: _buildFeaturedProjects()),

            SliverToBoxAdapter(
              child: _buildSectionTitle("Recently Added", () {}),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPropertyListItem(index),
                  childCount: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
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
                color: isSelected ? Colors.white : AppColors.primaryNavy,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              avatar: Icon(
                categories[index]['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : AppColors.primaryNavy,
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() => _selectedCategoryIndex = index);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryNavy : Colors.grey.shade200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text("See All", style: TextStyle(color: Colors.blue, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProjects() {
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
                image: NetworkImage("https://images.pexels.com/photos/323780/pexels-photo-323780.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ashiana Gold Residency", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Starting PKR 45 Lakh", style: TextStyle(color: Color(0xFFFFC400), fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyListItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg",
              width: 85, height: 85, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Modern 3-Bed Flat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Gulshan, Karachi", style: TextStyle(color: Colors.grey, fontSize: 11)),
                SizedBox(height: 8),
                Text("PKR 1.2 Cr", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}