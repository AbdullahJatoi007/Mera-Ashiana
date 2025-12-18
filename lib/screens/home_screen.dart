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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. The Header (Search & Buy/Rent Toggle)
          HomeTopSection(
            selectedOption: _selectedOption,
            statusBarHeight: statusBarHeight,
            onOptionSelected: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),

          // 2. Categories Section (Quick Access)
          SliverToBoxAdapter(
            child: _buildSectionTitle(loc.categories ?? "Categories", () {}),
          ),
          SliverToBoxAdapter(child: _buildCategoryGrid()),

          // 3. Featured Projects (Horizontal Scroll)
          SliverToBoxAdapter(
            child: _buildSectionTitle(loc.exploreProjects, () {}),
          ),
          SliverToBoxAdapter(child: _buildFeaturedProjects()),

          // 4. Recently Added Properties (Vertical List)
          SliverToBoxAdapter(
            child: _buildSectionTitle("Recently Added", () {}),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPropertyListItem(index),
              childCount: 10,
            ),
          ),

          // Bottom Padding for scroll breathing room
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              "See All",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'House', 'icon': Icons.home_work_outlined},
      {'name': 'Flat', 'icon': Icons.apartment_outlined},
      {'name': 'Plot', 'icon': Icons.landscape_outlined},
      {'name': 'Shop', 'icon': Icons.storefront_outlined},
    ];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories
            .map(
              (cat) => Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      cat['icon'] as IconData,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFeaturedProjects() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://images.pexels.com/photos/323780/pexels-photo-323780.jpeg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ashiana Gold Residency",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Starting PKR 45 Lakh",
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontSize: 12,
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

  Widget _buildPropertyListItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg",
              width: 100,
              height: 100,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Text(
                  "Gulshan-e-Iqbal, Karachi",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "PKR 1.2 Cr",
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.grey[400],
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
