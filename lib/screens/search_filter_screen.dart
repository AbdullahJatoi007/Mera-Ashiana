import 'package:flutter/material.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  String _purpose = "Buy";
  String _selectedType = "House";
  String _selectedCity = "Karachi";
  RangeValues _priceRange = const RangeValues(5, 50);
  int _selectedBeds = 3;

  final List<String> _cities = [
    "Karachi",
    "Lahore",
    "Islamabad",
    "Pindi",
    "Peshawar",
  ];
  final List<String> _propertyTypes = [
    "House",
    "Flat",
    "Plot",
    "Shop",
    "Office",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text(
          "Filters",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Reset",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 13,
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
                  _buildSectionTitle(theme, "Location"),
                  _buildCitySearchField(theme),
                  const SizedBox(height: 8),
                  _buildCityChips(theme),

                  Divider(
                    height: 32,
                    thickness: 0.5,
                    color: theme.dividerColor.withOpacity(0.1),
                  ),

                  _buildSectionTitle(theme, "Property Purpose"),
                  _buildPurposeToggle(theme),

                  const SizedBox(height: 20),

                  _buildSectionTitle(theme, "Property Type"),
                  _buildTypeGrid(theme),

                  Divider(
                    height: 32,
                    thickness: 0.5,
                    color: theme.dividerColor.withOpacity(0.1),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(theme, "Price Range"),
                      Text(
                        "${_priceRange.start.round()}M - ${_priceRange.end.round()}M",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  _buildPriceSlider(theme),

                  const SizedBox(height: 12),

                  _buildSectionTitle(theme, "Bedrooms"),
                  _buildBedSelection(theme),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildApplyButton(theme),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCitySearchField(ThemeData theme) {
    return SizedBox(
      height: 40,
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: "Search area (e.g. DHA Phase 6)",
          hintStyle: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: 18,
          ),
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

  Widget _buildCityChips(ThemeData theme) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          bool isSelected = _selectedCity == city;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (v) => setState(() => _selectedCity = city),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 11,
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

  Widget _buildPurposeToggle(ThemeData theme) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ["Buy", "Rent"].map((label) {
          bool isSelected = _purpose == label;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _purpose = label),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeGrid(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _propertyTypes.map((type) {
        bool isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSlider(ThemeData theme) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2,
        activeTrackColor: theme.colorScheme.primary,
        inactiveTrackColor: theme.dividerColor.withOpacity(0.1),
        thumbColor: theme.colorScheme.secondary,
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 8,
        ),
      ),
      child: RangeSlider(
        values: _priceRange,
        min: 0,
        max: 500,
        divisions: 50,
        onChanged: (val) => setState(() => _priceRange = val),
      ),
    );
  }

  Widget _buildBedSelection(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [1, 2, 3, 4, "5+"].map((e) {
        bool isSelected =
            _selectedBeds.toString() == e.toString() ||
            (_selectedBeds == 5 && e == "5+");
        return GestureDetector(
          onTap: () => setState(
            () => _selectedBeds = e == "5?" ? 5 : (e is int ? e : 5),
          ),
          child: Container(
            width: 55,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withOpacity(0.1),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              e.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Apply Filters",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
