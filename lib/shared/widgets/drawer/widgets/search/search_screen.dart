import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/shared/widgets/drawer/widgets/search/search_filter_screen.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/data/services/property_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_colors_dark.dart';
import '../../../../../features/properties/widgets/property_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

  static const List<Map<String, String>> _quickFilters = [
    {'label': 'All', 'value': 'all'},
    {'label': 'House', 'value': 'house'},
    {'label': 'Apartment/Flat', 'value': 'flat'},
    {'label': 'Plot', 'value': 'plot'},
    {'label': 'Commercial', 'value': 'commercial'},
    {'label': 'Other', 'value': 'other'},
  ];

  bool _hasSearchResults = false;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _canLoadMore = true;

  String _selectedQuickFilter = "All";
  List<Listing> _searchResults = [];
  int _currentPage = 1;
  Map<String, dynamic> _currentFilters = {};

  // Guards against stale/out-of-order responses when filters change quickly.
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _performSearch({}, isInitial: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isSearching && !_isLoadingMore && _canLoadMore) {
          _performSearch(
            _currentFilters,
            page: _currentPage + 1,
            isInitial: false,
          );
        }
      }
    });
  }

  /// Merges `changes` into the currently active filters and re-runs the
  /// search. Pass a `null` value to clear a key (e.g. {'type': null} to
  /// clear the type filter). This is what keeps quick filters, the search
  /// bar, and the full filter screen from stomping on each other's state.
  void _applyPartialFilters(Map<String, dynamic> changes) {
    final merged = Map<String, dynamic>.from(_currentFilters);
    changes.forEach((key, value) {
      if (value == null || value == '') {
        merged.remove(key);
      } else {
        merged[key] = value;
      }
    });
    _performSearch(merged, isInitial: true);
  }

  String _quickFilterLabelForType(String? type) {
    if (type == null) return "All";
    final match = _quickFilters.firstWhere(
      (f) => f['value'] == type,
      orElse: () => const {'label': 'All', 'value': 'all'},
    );
    return match['label']!;
  }

  Future<void> _performSearch(
    Map<String, dynamic> filters, {
    int page = 1,
    bool isInitial = true,
  }) async {
    if (isInitial) {
      _searchRequestId++;
    }
    final int requestId = _searchRequestId;

    if (isInitial) {
      setState(() {
        _isSearching = true;
        _hasSearchResults = true;
        _currentPage = page;
        _currentFilters = filters;
        _searchResults.clear();
        _canLoadMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _currentPage = page;
      });
    }

    try {
      final results = await PropertyService.fetchProperties(
        page: _currentPage,
        limit: 20,
        filters: filters,
      );

      // If a newer search started while this one was in flight, discard
      // this response so it can't corrupt the list with stale results.
      if (requestId != _searchRequestId) return;

      setState(() {
        if (results.isEmpty || results.length < 20) {
          _canLoadMore = false;
        }
        _searchResults.addAll(results);
        _isSearching = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (requestId != _searchRequestId) return;
      setState(() {
        _isSearching = false;
        _isLoadingMore = false;
      });
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
          _buildCompactHeader(loc, theme, isDark),
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

  Widget _buildCompactHeader(
    AppLocalizations loc,
    ThemeData theme,
    bool isDark,
  ) {
    final searchIconColor = isDark
        ? AppDarkColors.accentYellow
        : theme.colorScheme.primary;

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
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
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
                      _applyPartialFilters({
                        "query": v.trim().isEmpty ? null : v.trim(),
                      });
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
                        color: searchIconColor,
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
          _buildQuickFilterRow(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        final Map<String, dynamic>? filters = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchFilterScreen(initialFilters: _currentFilters),
          ),
        );

        if (filters != null) {
          setState(() {
            _selectedQuickFilter = _quickFilterLabelForType(
              filters['type'] as String?,
            );
          });
          _performSearch(filters, isInitial: true);
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

  Widget _buildQuickFilterRow(ThemeData theme, bool isDark) {
    final activeBg = isDark
        ? AppDarkColors.accentYellow
        : AppColors.accentYellow;
    final unselectedText = isDark ? AppDarkColors.textDark : AppColors.textDark;
    final borderThemeColor = isDark
        ? AppDarkColors.borderGrey
        : AppColors.borderGrey;

    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickFilters.length,
        itemBuilder: (context, i) {
          final filter = _quickFilters[i];
          bool isSelected = _selectedQuickFilter == filter['label'];

          return GestureDetector(
            onTap: () {
              setState(() => _selectedQuickFilter = filter['label']!);
              _applyPartialFilters({
                'type': filter['value'] == 'all' ? null : filter['value'],
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? activeBg : borderThemeColor,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filter['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : unselectedText,
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
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
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
    onTap: () => _applyPartialFilters({"query": t}),
  );

  Widget _buildPopularGrid(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ["Bahria", "DHA", "Clifton", "Gulshan"]
          .map(
            (e) => GestureDetector(
              onTap: () => _applyPartialFilters({"city": e}),
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
