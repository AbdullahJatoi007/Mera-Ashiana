import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildCompactHeader(loc, theme),
          Expanded(
            child: _hasSearchResults
                ? _buildResultsList(theme)
                : _buildInitialState(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        // Fix: Use surface instead of AppColors.white
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.4 : 0.05,
            ),
            blurRadius: 10,
          ),
        ],
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
                    onSubmitted: (v) =>
                        setState(() => _hasSearchResults = true),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Area, City or Project...",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterButton(theme),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickFilterRow(theme),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchFilterScreen()),
        );
        setState(() => _hasSearchResults = true);
      },
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.tune, color: theme.colorScheme.onSecondary, size: 20),
      ),
    );
  }

  Widget _buildQuickFilterRow(ThemeData theme) {
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
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filters[i],
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(ThemeData theme, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Fix card color
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image part stays largely same, but badges use theme
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "FOR SALE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PKR ${data['price']}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  data['title']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      data['location']!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Divider(height: 20, color: theme.dividerColor.withOpacity(0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _specItem(
                      theme,
                      Icons.king_bed_outlined,
                      "${data['beds']} Beds",
                    ),
                    _specItem(
                      theme,
                      Icons.bathtub_outlined,
                      "${data['baths']} Baths",
                    ),
                    _specItem(theme, Icons.square_foot, data['size']!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specItem(ThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Helper methods for Initial State...
  Widget _buildInitialState(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Recent Searches",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        _buildHistoryTile(theme, "DHA Phase 6"),
        const SizedBox(height: 20),
        Text(
          "Popular Hubs",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        _buildPopularGrid(theme),
      ],
    );
  }

  Widget _buildHistoryTile(ThemeData theme, String t) => ListTile(
    leading: const Icon(Icons.history, size: 20, color: Colors.grey),
    title: Text(
      t,
      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
    ),
    trailing: const Icon(Icons.north_west, size: 14),
    contentPadding: EdgeInsets.zero,
  );

  Widget _buildPopularGrid(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ["Bahria", "DHA", "Clifton", "Gulshan"]
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Text(
                e,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildResultsList(ThemeData theme) {
    // Note: You would pass the theme into the card builder here
    return const Center(child: Text("Results here..."));
  }
}
