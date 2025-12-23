import 'package:flutter/material.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/search_filter_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _hasSearchResults = false;
  String _selectedQuickFilter = "All";

  // --- DUMMY DATA MODEL ---
  final List<Map<String, String>> _dummyProperties = [
    {
      "image": "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=600&auto=format&fit=crop",
      "price": "4.5 Crore",
      "title": "Modern 500 Sq.Yd Villa",
      "location": "DHA Phase 6, Karachi",
      "beds": "4",
      "baths": "5",
      "size": "500 Sq.Yd",
    },
    {
      "image": "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&auto=format&fit=crop",
      "price": "85 Lakh",
      "title": "Luxury Apartment",
      "location": "Bahria Town, Lahore",
      "beds": "2",
      "baths": "2",
      "size": "1200 Sq.Ft",
    },
    {
      "image": "https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=600&auto=format&fit=crop",
      "price": "12 Crore",
      "title": "Palatial Mansion",
      "location": "Sector F-7, Islamabad",
      "beds": "6",
      "baths": "7",
      "size": "2 Kanal",
    },
    {
      "image": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop",
      "price": "2.2 Crore",
      "title": "Commercial Plot",
      "location": "Gulberg III, Lahore",
      "beds": "0",
      "baths": "0",
      "size": "10 Marla",
    },
  ];

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildCompactHeader(loc),
          Expanded(
            child: _hasSearchResults
                ? _buildResultsList()
                : _buildInitialState(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    onSubmitted: (v) => setState(() => _hasSearchResults = true),
                    decoration: InputDecoration(
                      hintText: "Area, City or Project...",
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryNavy, size: 20),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickFilterRow(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchFilterScreen()));
        setState(() => _hasSearchResults = true);
      },
      child: Container(
        height: 44, width: 44,
        decoration: BoxDecoration(color: AppColors.accentYellow, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.tune, color: AppColors.primaryNavy, size: 20),
      ),
    );
  }

  Widget _buildQuickFilterRow() {
    final filters = ["All", "Houses", "Flats", "Plots", "Rent"];
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          bool isSelected = _selectedQuickFilter == filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedQuickFilter = filters[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? AppColors.primaryNavy : Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Text(filters[i], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }

  // --- RESULTS LIST WITH DUMMY DATA ---
  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dummyProperties.length,
      itemBuilder: (context, index) {
        final property = _dummyProperties[index];
        return _buildPropertyCard(property);
      },
    );
  }

  Widget _buildPropertyCard(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  data['image']!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accentYellow, borderRadius: BorderRadius.circular(6)),
                  child: const Text("FOR SALE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PKR ${data['price']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryNavy)),
                const SizedBox(height: 2),
                Text(data['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(data['location']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const Divider(height: 20, thickness: 0.5),
                // Specs Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _specItem(Icons.king_bed_outlined, "${data['beds']} Beds"),
                    _specItem(Icons.bathtub_outlined, "${data['baths']} Baths"),
                    _specItem(Icons.square_foot, data['size']!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryNavy.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildInitialState() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        _buildHistoryTile("DHA Phase 6"),
        const SizedBox(height: 20),
        const Text("Popular Hubs", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        const SizedBox(height: 10),
        _buildPopularGrid(),
      ],
    );
  }

  Widget _buildHistoryTile(String t) => ListTile(
    leading: const Icon(Icons.history, size: 20, color: Colors.grey),
    title: Text(t, style: const TextStyle(fontSize: 14)),
    trailing: const Icon(Icons.north_west, size: 14),
    contentPadding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
  );

  Widget _buildPopularGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ["Bahria", "DHA", "Clifton", "Gulshan"].map((e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
        child: Text(e, style: const TextStyle(fontSize: 12)),
      )).toList(),
    );
  }
}