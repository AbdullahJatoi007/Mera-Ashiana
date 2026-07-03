import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import 'package:mera_ashiana/core/theme/app_colors_dark.dart';

class SearchFilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const SearchFilterScreen({super.key, this.initialFilters});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _locationController = TextEditingController();

  late String _purpose;
  late String _selectedType;
  late String _selectedCity;
  RangeValues? _priceRange; // null = "Any"
  int? _selectedBeds; // null = "Any"

  final List<String> _cities = [
    "Karachi",
    "Lahore",
    "Islamabad",
    "Rawalpindi",
    "Peshawar",
  ];

  // "Any" added so users can explicitly clear the type filter from this screen
  final List<String> _propertyTypes = [
    "Any",
    "House",
    "Flat",
    "Plot",
    "Commercial",
    "Other",
  ];

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

    _purpose = (filters?["purpose"] == "rent") ? "Rent" : "Buy";

    final rawType = filters?["type"] as String?;
    _selectedType = rawType != null
        ? "${rawType[0].toUpperCase()}${rawType.substring(1)}"
        : "Any";

    _selectedCity = filters?["city"] as String? ?? "Karachi";
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
                  _buildSectionTitle(theme, "Location"),
                  _buildCitySearchField(theme, textColor),
                  const SizedBox(height: 12),
                  _buildCityChips(theme, accentYellow, textColor),
                  Divider(
                    height: 40,
                    thickness: 0.5,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                  _buildSectionTitle(theme, "Property Purpose"),
                  _buildPurposeToggle(theme, accentYellow, textColor),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, "Property Type"),
                  _buildTypeGrid(theme, accentYellow, textColor),
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
      _purpose = "Buy";
      _selectedType = "Any";
      _selectedCity = "Karachi";
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

  Widget _buildCityChips(ThemeData theme, Color accentYellow, Color textColor) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = _selectedCity == city;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCity = city),
              selectedColor: accentYellow,
              backgroundColor: theme.colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
              ),
            ),
          );
        },
      ),
    );
  }

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
        children: ["Buy", "Rent"].map((label) {
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

  Widget _buildTypeGrid(ThemeData theme, Color accentYellow, Color textColor) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _propertyTypes.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? accentYellow : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? accentYellow
                    : theme.dividerColor.withOpacity(0.2),
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.black : textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
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
    // Wrap instead of a fixed Row so it doesn't overflow on smaller screens
    // now that there are 6 options instead of 5.
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
            final String apiPurpose = _purpose == "Buy" ? "sale" : "rent";
            Navigator.pop(context, {
              "purpose": apiPurpose,
              if (_selectedType != "Any") "type": _selectedType.toLowerCase(),
              "city": _selectedCity,
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
