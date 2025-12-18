import 'package:flutter/material.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  // Filter States
  String _purpose = "Buy";
  String _selectedType = "House";
  String _selectedCity = "Karachi";
  RangeValues _priceRange = const RangeValues(5, 50); // In Millions
  int _selectedBeds = 3;

  final List<String> _cities = [
    "Karachi",
    "Lahore",
    "Islamabad",
    "Rawalpindi",
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
        title: const Text(
          "Filter Search",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Location & City Search
                  _buildSectionTitle("Location"),
                  _buildCitySearchField(primaryNavy),
                  const SizedBox(height: 15),
                  _buildCityChips(primaryNavy, accentYellow),

                  const SizedBox(height: 30),

                  // 2. Purpose Toggle
                  _buildSectionTitle("Property Purpose"),
                  _buildPurposeToggle(primaryNavy),

                  const SizedBox(height: 30),

                  // 3. Property Type
                  _buildSectionTitle("Property Type"),
                  _buildTypeGrid(primaryNavy, accentYellow),

                  const SizedBox(height: 30),

                  // 4. Price Range
                  _buildSectionTitle(
                    "Price Range (PKR ${_priceRange.start.round()}M - ${_priceRange.end.round()}M)",
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    activeColor: primaryNavy,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (val) => setState(() => _priceRange = val),
                  ),

                  const SizedBox(height: 30),

                  // 5. Bedrooms
                  _buildSectionTitle("Bedrooms"),
                  _buildBedSelection(primaryNavy, accentYellow),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildApplyButton(primaryNavy),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A1D37),
        ),
      ),
    );
  }

  Widget _buildCitySearchField(Color navy) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search specific area (e.g. DHA, Gulshan)",
        prefixIcon: Icon(Icons.search, color: navy, size: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCityChips(Color navy, Color yellow) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _cities.map((city) {
          bool isSelected = _selectedCity == city;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (v) => setState(() => _selectedCity = city),
              selectedColor: navy,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : navy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPurposeToggle(Color navy) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ["Buy", "Rent"].map((label) {
          bool isSelected = _purpose == label;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _purpose = label),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(color: navy, fontWeight: FontWeight.bold),
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
      spacing: 10,
      runSpacing: 10,
      children: _propertyTypes.map((type) {
        bool isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? yellow : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? yellow : Colors.grey.shade200,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
        bool isS =
            _selectedBeds.toString() == e.toString() ||
            (_selectedBeds == 5 && e == "5+");
        return GestureDetector(
          onTap: () => setState(() => _selectedBeds = e == "5+" ? 5 : e as int),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: isS ? navy : Colors.grey.shade100,
            child: Text(
              e.toString(),
              style: TextStyle(
                color: isS ? Colors.white : Colors.grey,
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
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            "Apply Filters",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
