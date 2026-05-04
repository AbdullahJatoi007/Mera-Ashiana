import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/shared/widgets/drawer/widgets/search/search_filter_screen.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/data/services/property_service.dart';


import '../../../../../features/properties/widgets/property_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _hasSearchResults = false;
  bool _isSearching = false;
  String _selectedQuickFilter = "All";
  List<Listing> _searchResults = [];

  Future<void> _performSearch(Map<String, dynamic> filters) async {
    setState(() {
      _isSearching = true;
      _hasSearchResults = true;
    });

    try {
      final results = await PropertyService.fetchProperties(filters: filters);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      debugPrint("Search Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildCompactHeader(loc, theme),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _hasSearchResults
                ? _buildResultsList(theme, isDark)
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
                    onSubmitted: (v) {
                      if (v.isNotEmpty) {
                        _performSearch({"query": v});
                      }
                    },
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
        final Map<String, dynamic>? filters = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchFilterScreen()),
        );

        if (filters != null) {
          _performSearch(filters);
        }
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

  // ✅ MERGED: Updated Quick Filter logic
  Widget _buildQuickFilterRow(ThemeData theme) {
    final List<Map<String, String>> filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'House', 'value': 'house'},
      {'label': 'Apartment/Flat', 'value': 'flat'},
      {'label': 'Plot', 'value': 'plot'},
      {'label': 'Commercial', 'value': 'commercial'},
      {'label': 'Other', 'value': 'other'},
    ];

    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final filter = filters[i];
          bool isSelected = _selectedQuickFilter == filter['label'];

          return GestureDetector(
            onTap: () {
              setState(() => _selectedQuickFilter = filter['label']!);

              // Construct parameters dynamically
              Map<String, dynamic> searchParams = {};
              if (filter['value'] != 'all') {
                searchParams['type'] = filter['value'];
              }

              _performSearch(searchParams);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filter['label']!,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme, bool isDark) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          "No properties found matching your filters.",
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return PropertyListItem(
          listing: _searchResults[index],
          theme: theme,
          isDark: isDark,
        );
      },
    );
  }

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
    onTap: () => _performSearch({"query": t}),
  );

  Widget _buildPopularGrid(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ["Bahria", "DHA", "Clifton", "Gulshan"]
          .map(
            (e) => GestureDetector(
              onTap: () => _performSearch({"city": e}),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  e,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
