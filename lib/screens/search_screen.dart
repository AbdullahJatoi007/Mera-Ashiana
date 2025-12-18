import 'package:flutter/material.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/search_filter_screen.dart'; // Import your filter file

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // To toggle between "Search Suggestions" and "Search Results"
  bool _hasSearchResults = false;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Search Header (Stays fixed at top)
          _buildSearchHeader(loc),

          // 2. Dynamic Body
          Expanded(
            child: _hasSearchResults
                ? _buildResultsList() // Show properties if searched
                : _buildInitialState(), // Show history/popular if idle
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSearchHeader(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: TextField(
        onSubmitted: (value) => setState(() => _hasSearchResults = true),
        decoration: InputDecoration(
          hintText: "Search city, area or project...",
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryNavy),
          suffixIcon: GestureDetector(
            onTap: () async {
              // Open your separate filter screen
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchFilterScreen(),
                ),
              );
              // After returning, show results
              setState(() => _hasSearchResults = true);
            },
            child: Container(
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
          ),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // --- INITIAL STATE (Before Search) ---
  Widget _buildInitialState() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Recent Searches",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        _buildHistoryTile("DHA Phase 8, Karachi"),
        _buildHistoryTile("3 Bed Apartments in Islamabad"),
        const SizedBox(height: 30),
        const Text(
          "Popular Areas",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        _buildPopularGrid(),
      ],
    );
  }

  // --- RESULTS STATE (After Search) ---
  Widget _buildResultsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "124 Properties Found",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _hasSearchResults = false),
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                label: const Text("Clear", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5, // Replace with dynamic list
            itemBuilder: (context, index) => _buildPropertyCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "FOR SALE",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PKR 4.5 Crore",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Luxury 3 Bed Apartment",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Text(
                  "DHA Phase 6, Karachi",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Divider(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardIcon(Icons.king_bed, "3 Beds"),
                    _cardIcon(Icons.bathtub, "3 Baths"),
                    _cardIcon(Icons.square_foot, "240 Sq.Yd"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHistoryTile(String title) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.north_west, size: 16),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPopularGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ["Bahria Town", "DHA", "Clifton", "Gulshan"]
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(e, style: const TextStyle(fontSize: 13)),
            ),
          )
          .toList(),
    );
  }
}
