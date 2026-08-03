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

  // The backend has no free-text search param (confirmed: getAll.ts only
  // reads city/province/type/status/area/minArea/maxArea/minPrice/maxPrice/
  // bedrooms/bathrooms/sortBy/page/limit — no `query`/`q`/`keyword`).
  // So any typed text (entered via SearchFilterScreen's location field,
  // which already returns it as `filters['query']`) is matched client-side
  // against fetched listings, auto-paginating until enough matches are found.
  static const int _minQueryMatches = 15;
  static const int _maxQueryPagesToFetch = 8; // safety cap

  bool _hasSearchResults = false;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _canLoadMore = true;

  String _selectedQuickFilter = "All";
  List<Listing> _searchResults = []; // what's actually shown (post text-filter)
  int _currentPage = 1;
  Map<String, dynamic> _currentFilters = {}; // may include 'query'

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
  /// clear the type filter).
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

  /// Whether a listing matches the typed free-text query. Checked against
  /// every field a user would plausibly type: title, location, city,
  /// province, neighborhood, and type — case-insensitive substring match.
  bool _matchesTextQuery(Listing listing, String query) {
    final q = query.toLowerCase();
    final haystacks = [
      listing.title,
      listing.location,
      listing.city,
      listing.province,
      listing.neighborhood,
      listing.type,
    ];
    return haystacks.any((field) => (field ?? '').toLowerCase().contains(q));
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

    // 'query' is a client-only concept — the backend doesn't recognize it,
    // so it's stripped before hitting the API and applied locally instead.
    final String? textQuery = (filters['query'] as String?)?.trim();
    final Map<String, dynamic> apiFilters = Map<String, dynamic>.from(filters)
      ..remove('query');

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
      final List<Listing> collected = isInitial ? [] : List.of(_searchResults);
      int pagesFetchedThisRun = 0;
      int workingPage = _currentPage;
      bool canLoadMore = true;

      while (true) {
        final results = await PropertyService.fetchProperties(
          page: workingPage,
          limit: 20,
          filters: apiFilters,
        );

        if (requestId != _searchRequestId) return; // superseded — bail out

        pagesFetchedThisRun++;
        canLoadMore = results.length >= 20;

        final matched = (textQuery == null || textQuery.isEmpty)
            ? results
            : results.where((l) => _matchesTextQuery(l, textQuery)).toList();

        collected.addAll(matched);

        final bool needMore =
            textQuery != null &&
            textQuery.isNotEmpty &&
            collected.length < _minQueryMatches &&
            canLoadMore &&
            pagesFetchedThisRun < _maxQueryPagesToFetch;

        if (!needMore) break;
        workingPage++;
      }

      if (requestId != _searchRequestId) return;

      setState(() {
        _searchResults = collected;
        _currentPage = workingPage;
        _canLoadMore = canLoadMore;
        _isSearching = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (requestId != _searchRequestId) return;
      // 🔧 FIX: never leave the screen stuck mid-search on failure — fall
      // back to whatever was already loaded (or empty on first load) so
      // the user always sees *something* actionable instead of a frozen
      // spinner.
      setState(() {
        _isSearching = false;
        _isLoadingMore = false;
        _canLoadMore = false;
      });
      debugPrint("Search Error: $e");
    }
  }

  /// Opens the full filter/search screen (which owns the actual text-entry
  /// field for area/city/project name), pre-filled with whatever's active,
  /// and applies whatever comes back — including an empty result, which
  /// correctly resets everything to the default unfiltered listing feed.
  Future<void> _openFilterScreen() async {
    final Map<String, dynamic>? filters = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchFilterScreen(initialFilters: _currentFilters),
      ),
    );

    // User backed out without applying — leave current results untouched.
    if (filters == null) return;

    setState(() {
      _selectedQuickFilter = _quickFilterLabelForType(
        filters['type'] as String?,
      );
    });
    _performSearch(filters, isInitial: true);
  }

  /// Clears every active filter/query and returns to the default,
  /// unfiltered listing feed — used by the "x" shown once a search is active.
  void _clearSearch() {
    setState(() => _selectedQuickFilter = "All");
    _performSearch({}, isInitial: true);
  }

  /// Human-readable summary of whatever's currently searched/filtered,
  /// shown inside the tappable search box instead of raw typing.
  String? get _activeSearchSummary {
    final parts = <String>[];
    final query = _currentFilters['query'] as String?;
    final city = _currentFilters['city'] as String?;
    if (query != null && query.isNotEmpty) parts.add(query);
    if (city != null && city.isNotEmpty && city != query) parts.add(city);
    return parts.isEmpty ? null : parts.join(' • ');
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
    final summary = _activeSearchSummary;

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
                child: InkWell(
                  onTap: _openFilterScreen,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: searchIconColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            summary ?? "Area, City or Project...",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: summary != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                              fontWeight: summary != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (summary != null)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                      ],
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
      onTap: _openFilterScreen,
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
