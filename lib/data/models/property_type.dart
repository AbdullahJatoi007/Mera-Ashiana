/// Mirrors the backend's `listings_type` Prisma enum / LISTING_TYPES
/// constant exactly, so the picker always offers every type the backend
/// actually accepts — including the newer granular subtypes, not just
/// the 4-5 legacy top-level ones.
class PropertyType {
  final String value; // raw enum value sent to the API, e.g. 'commercial_plot'
  final String label; // human-readable, e.g. 'Commercial Plot'

  const PropertyType({required this.value, required this.label});

  static const List<PropertyType> all = [
    PropertyType(value: 'house', label: 'House'),
    PropertyType(value: 'apartment', label: 'Apartment'),
    PropertyType(value: 'plot', label: 'Plot'),
    PropertyType(value: 'commercial', label: 'Commercial'),
    PropertyType(value: 'flat', label: 'Flat'),
    PropertyType(value: 'upper_portion', label: 'Upper Portion'),
    PropertyType(value: 'lower_portion', label: 'Lower Portion'),
    PropertyType(value: 'farm_house', label: 'Farm House'),
    PropertyType(value: 'room', label: 'Room'),
    PropertyType(value: 'penthouse', label: 'Penthouse'),
    PropertyType(value: 'residential_plot', label: 'Residential Plot'),
    PropertyType(value: 'commercial_plot', label: 'Commercial Plot'),
    PropertyType(value: 'agricultural_land', label: 'Agricultural Land'),
    PropertyType(value: 'industrial_land', label: 'Industrial Land'),
    PropertyType(value: 'plot_file', label: 'Plot File'),
    PropertyType(value: 'plot_form', label: 'Plot Form'),
    PropertyType(value: 'office', label: 'Office'),
    PropertyType(value: 'shop', label: 'Shop'),
    PropertyType(value: 'warehouse', label: 'Warehouse'),
    PropertyType(value: 'factory', label: 'Factory'),
    PropertyType(value: 'building', label: 'Building'),
    PropertyType(value: 'other', label: 'Other'),
  ];

  /// Looks up the display label for a raw backend value, e.g. for showing
  /// the current selection. Falls back to the raw value if unrecognized
  /// (defensive — shouldn't happen if the backend enum and this list stay
  /// in sync, but avoids ever showing "null" or crashing).
  static String labelFor(String? value) {
    if (value == null) return 'Any';
    final match = all.where((t) => t.value == value);
    return match.isEmpty ? value : match.first.label;
  }
}
