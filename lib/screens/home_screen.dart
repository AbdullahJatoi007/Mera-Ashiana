import 'package:flutter/material.dart';
import 'package:mera_ashiana/screens/home/home_top_section.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/home/widgets/home_top_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedOption = 'BUY';
  int _selectedCategoryIndex = 0; // Track active category

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Ultra Compact Header
          HomeTopSection(
            selectedOption: _selectedOption,
            statusBarHeight: statusBarHeight,
            onOptionSelected: (value) {
              setState(() => _selectedOption = value);
            },
          ),

          // 2. Polished Categories (Chip Style)
          SliverPadding(
            padding: const EdgeInsets.only(top: 15, bottom: 5),
            sliver: SliverToBoxAdapter(child: _buildCategoryList()),
          ),

          // 3. Featured Projects
          SliverToBoxAdapter(
            child: _buildSectionTitle(loc.exploreProjects, () {}),
          ),
          SliverToBoxAdapter(child: _buildFeaturedProjects()),

          // 4. Recently Added
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
    );
  }

  // --- RE-POLISHED CATEGORY LIST (CHIP STYLE) ---
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
                  color: isSelected
                      ? AppColors.primaryNavy
                      : Colors.grey.shade200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- TIGHTENED SECTION TITLE ---
  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16, // Slightly smaller for professional look
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text(
              "See All",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- POLISHED FEATURED PROJECTS ---
  Widget _buildFeaturedProjects() {
    return SizedBox(
      height: 180, // Reduced from 220 to optimize space
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ashiana Gold Residency",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Starting PKR 45 Lakh",
                    style: TextStyle(
                      color: Color(0xFFFFC400),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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

  // --- CLEANER PROPERTY LIST ITEM ---
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
                const Text(
                  "Modern 3-Bed Flat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "Gulshan, Karachi",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "PKR 1.2 Cr",
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
