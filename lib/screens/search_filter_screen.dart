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
    const Color primaryNavy = Color(0xFF0A1D37);
    const Color accentYellow = Color(0xFFFFC400);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        // Reduced height to save space
        title: const Text(
          "Filters",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryNavy, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {}, // Reset logic
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Tighter horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Unified Location Section
                  _buildSectionTitle("Location"),
                  _buildCitySearchField(primaryNavy),
                  const SizedBox(height: 8),
                  // Reduced gap
                  _buildCityChips(primaryNavy, accentYellow),

                  const Divider(height: 32, thickness: 0.5),
                  // Visual separator helps define space

                  // 2. Purpose & Type (Side by Side or tightly packed)
                  _buildSectionTitle("Property Purpose"),
                  _buildPurposeToggle(primaryNavy),

                  const SizedBox(height: 20),

                  _buildSectionTitle("Property Type"),
                  _buildTypeGrid(primaryNavy, accentYellow),

                  const Divider(height: 32, thickness: 0.5),

                  // 3. Price Range - Optimized Slider Space
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Price Range"),
                      Text(
                        "${_priceRange.start.round()}M - ${_priceRange.end.round()}M",
                        style: const TextStyle(
                          color: primaryNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                    ),
                    child: RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      activeColor: primaryNavy,
                      inactiveColor: Colors.grey.shade200,
                      onChanged: (val) => setState(() => _priceRange = val),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Bedrooms
                  _buildSectionTitle("Bedrooms"),
                  _buildBedSelection(primaryNavy, accentYellow),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildApplyButton(primaryNavy),
        ],
      ),
    );
  }

  // --- COMPACT UI COMPONENTS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A1D37),
        ),
      ),
    );
  }

  Widget _buildCitySearchField(Color navy) {
    return SizedBox(
      height: 40, // Fixed smaller height
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search area (e.g. DHA Phase 6)",
          hintStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(Icons.search, color: navy, size: 18),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCityChips(Color navy, Color yellow) {
    return SizedBox(
      height: 35, // Restricted height for chips
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
              selectedColor: navy,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : navy,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurposeToggle(Color navy) {
    return Container(
      height: 40, // Slimmer toggle
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black12, blurRadius: 2)]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: navy,
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

  Widget _buildTypeGrid(Color navy, Color yellow) {
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
              color: isSelected ? navy : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? navy : Colors.grey.shade300,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : navy,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBedSelection(Color navy, Color yellow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [1, 2, 3, 4, "5+"].map((e) {
        bool isSelected =
            _selectedBeds.toString() == e.toString() ||
            (_selectedBeds == 5 && e == "5+");
        return GestureDetector(
          onTap: () => setState(() => _selectedBeds = e == "5+" ? 5 : e as int),
          child: Container(
            width: 55,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? navy : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? navy : Colors.grey.shade200,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              e.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton(Color navy) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Apply Filters",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
