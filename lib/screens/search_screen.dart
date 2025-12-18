import 'package:flutter/material.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Static state for UI toggles
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Houses",
    "Apartments",
    "Plots",
    "Commercial",
  ];

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Search Header Section
          _buildSearchHeader(loc),

          // 2. Filter Categories
          _buildCategoryFilter(),

          // 3. Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Recent Searches", () {}),
                  _buildRecentSearchTile("DHA Phase 6, Karachi"),
                  _buildRecentSearchTile("3 Bedroom Apartment in Gulshan"),

                  const SizedBox(height: 30),

                  _buildSectionHeader("Popular Areas", () {}),
                  const SizedBox(height: 10),
                  _buildPopularAreaGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSearchHeader(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search city, area or project...",
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryNavy,
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryNavy
                      : AppColors.borderGrey,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onClear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        TextButton(
          onPressed: onClear,
          child: const Text(
            "Clear All",
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearchTile(String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history, color: AppColors.textGrey),
      title: Text(text, style: const TextStyle(color: AppColors.textGrey)),
      trailing: const Icon(
        Icons.north_west,
        size: 18,
        color: AppColors.textGrey,
      ),
      onTap: () {},
    );
  }

  Widget _buildPopularAreaGrid() {
    // Static list of popular areas
    final areas = [
      "Bahria Town",
      "DHA",
      "Clifton",
      "Gulshan",
      "E-11 Islamabad",
      "Model Town",
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: areas
          .map(
            (area) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Text(
                area,
                style: const TextStyle(color: AppColors.textDark),
              ),
            ),
          )
          .toList(),
    );
  }
}
