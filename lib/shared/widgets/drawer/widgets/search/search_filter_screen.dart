import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import 'package:mera_ashiana/core/theme/app_colors_dark.dart';
import 'package:mera_ashiana/shared/widgets/property_type_field.dart';
import 'package:mera_ashiana/shared/widgets/city_field.dart';

class SearchFilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const SearchFilterScreen({super.key, this.initialFilters});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _locationController = TextEditingController();

  // "Buy" | "Rent" | "Both" — "Both" means no status filter is sent at all,
  // since the backend's listings_status enum only has sale/rent, no
  // combined value exists to send.
  late String _purpose;
  String? _selectedTypeValue; // raw backend value, null = "Any"
  String? _selectedCity; // null = "Any City"
  RangeValues? _priceRange; // null = "Any"
  int? _selectedBeds; // null = "Any"

  final List<List<int>?> _priceRanges = [
    null, // Any
    [0, 5],
    [5, 10],
    [10, 20],
    [20, 50],
    [50, 100],
    [100, 500],
  ];

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    final filters = widget.initialFilters;

    // 🔧 FIX: backend reads `status`, not `purpose` — the old key name
    // meant Buy/Rent was silently never applied server-side. Reading the
    // correct key here too, so re-opening the filter screen reflects
    // whatever's actually active.
    final rawStatus = filters?["status"] as String?;
    _purpose = rawStatus == "rent"
        ? "Rent"
        : rawStatus == "sale"
        ? "Buy"
        : "Both"; // no status key present = Both

    _selectedTypeValue = filters?["type"] as String?;
    _selectedCity = filters?["city"] as String?;
    _locationController.text = filters?["query"] as String? ?? "";

    final minPrice = filters?["min_price"];
    final maxPrice = filters?["max_price"];
    _priceRange = (minPrice != null && maxPrice != null)
        ? RangeValues(
            (minPrice / 1000000).toDouble(),
            (maxPrice / 1000000).toDouble(),
          )
        : null;

    _selectedBeds = filters?["beds"] as int?;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryNavy = isDark
        ? AppDarkColors.primaryNavy
        : AppColors.primaryNavy;
    final accentYellow = isDark
        ? AppDarkColors.accentYellow
        : AppColors.accentYellow;
    final textColor = isDark ? AppDarkColors.textPrimary : AppColors.textDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Filters",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _resetFilters,
              child: Text(
                "Reset",
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSectionTitle(theme, "Area / Project"),
                  _buildCitySearchField(theme, textColor),
                  const SizedBox(height: 16),
                  _buildSectionTitle(theme, "City"),
                  CityField(
                    selectedValue: _selectedCity,
                    onChanged: (value) => setState(() => _selectedCity = value),
                  ),
                  Divider(
                    height: 40,
                    thickness: 0.5,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                  _buildSectionTitle(theme, "Property Purpose"),
                  _buildPurposeToggle(theme, accentYellow, textColor),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, "Property Type"),
                  PropertyTypeField(
                    selectedValue: _selectedTypeValue,
                    onChanged: (value) =>
                        setState(() => _selectedTypeValue = value),
                  ),
                  Divider(
                    height: 40,
                    thickness: 0.5,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(theme, "Price Range"),
                      Text(
                        _priceRange == null
                            ? "Any"
                            : "${_priceRange!.start.round()}M - ${_priceRange!.end.round()}M",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRangeChips(theme, accentYellow, textColor),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, "Bedrooms"),
                  _buildBedSelection(theme, accentYellow, textColor),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildApplyButton(primaryNavy),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      // 🔧 Reset now goes to "Both" (no status filter) rather than
      // silently forcing Buy — matches what "reset" should actually mean.
      _purpose = "Both";
      _selectedTypeValue = null;
      _selectedCity = null;
      _locationController.clear();
      _priceRange = null;
      _selectedBeds = null;
    });
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCitySearchField(ThemeData theme, Color textColor) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: _locationController,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Search area (e.g. DHA Phase 6)",
          hintStyle: TextStyle(fontSize: 13, color: textColor.withOpacity(0.4)),
          prefixIcon: Icon(Icons.search, color: textColor, size: 20),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔧 Now a 3-way toggle: Buy / Rent / Both.
  Widget _buildPurposeToggle(
    ThemeData theme,
    Color accentYellow,
    Color textColor,
  ) {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: ["Buy", "Rent", "Both"].map((label) {
          final isSelected = _purpose == label;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _purpose = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? accentYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeChips(
    ThemeData theme,
    Color accentYellow,
    Color textColor,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _priceRanges.map((range) {
        final isSelected = range == null
            ? _priceRange == null
            : (_priceRange != null &&
                  _priceRange!.start.round() == range[0] &&
                  _priceRange!.end.round() == range[1]);
        return GestureDetector(
          onTap: () => setState(() {
            _priceRange = range == null
                ? null
                : RangeValues(range[0]!.toDouble(), range[1]!.toDouble());
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? accentYellow : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? accentYellow
                    : theme.dividerColor.withOpacity(0.2),
              ),
            ),
            child: Text(
              range == null ? "Any" : "${range[0]}M - ${range[1]}M",
              style: TextStyle(
                color: isSelected ? Colors.black : textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBedSelection(
    ThemeData theme,
    Color accentYellow,
    Color textColor,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <dynamic>[null, 1, 2, 3, 4, "5+"].map((e) {
        final label = e == null ? "Any" : e.toString();
        final isSelected = e == null
            ? _selectedBeds == null
            : (_selectedBeds != null &&
                  (_selectedBeds.toString() == e.toString() ||
                      (_selectedBeds == 5 && e == "5+")));
        return GestureDetector(
          onTap: () => setState(() {
            if (e == null) {
              _selectedBeds = null;
            } else if (e == "5+") {
              _selectedBeds = 5;
            } else {
              _selectedBeds = e as int;
            }
          }),
          child: Container(
            width: 56,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? accentYellow : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? accentYellow
                    : theme.dividerColor.withOpacity(0.1),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton(Color primaryNavy) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // 🔧 FIX: correct key is `status` (not `purpose`, which the
            // backend never read). "Both" omits the key entirely — there's
            // no combined enum value on the backend, so "no filter" is
            // the correct way to request both sale and rent listings.
            final String? apiStatus = _purpose == "Buy"
                ? "sale"
                : _purpose == "Rent"
                ? "rent"
                : null;

            Navigator.pop(context, {
              if (apiStatus != null) "status": apiStatus,
              if (_selectedTypeValue != null) "type": _selectedTypeValue,
              if (_selectedCity != null) "city": _selectedCity,
              "query": _locationController.text.trim(),
              if (_priceRange != null)
                "min_price": (_priceRange!.start * 1000000).round(),
              if (_priceRange != null)
                "max_price": (_priceRange!.end * 1000000).round(),
              if (_selectedBeds != null) "beds": _selectedBeds,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            "Apply Filters",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
