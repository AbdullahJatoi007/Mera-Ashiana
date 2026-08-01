// lib/features/home/models/property_category.dart

import 'package:flutter/material.dart';

/// A user-facing filter category (shown as a chip) mapped to the set of
/// raw `listings.type` enum values (from the Prisma schema) that should
/// be considered part of it.
///
/// The backend's `listings_type` enum has grown over time — e.g. `apartment`
/// is a legacy value, while newer listings use more specific subtypes like
/// `flat`, `penthouse`, or `room`. This mapping absorbs that on the client
/// so the UI only needs to reason about a small set of categories.
class PropertyCategory {
  final String label;
  final IconData icon;

  /// Raw `type` values (as stored in the DB / returned by the API,
  /// lowercase) that belong to this category. Empty list = no filtering
  /// (used for "All").
  final List<String> matchingTypes;

  const PropertyCategory({
    required this.label,
    required this.icon,
    required this.matchingTypes,
  });

  /// Whether a listing's raw `type` string belongs to this category.
  bool matches(String? rawType) {
    if (matchingTypes.isEmpty) return true; // "All"
    return matchingTypes.contains((rawType ?? '').toLowerCase());
  }

  static const List<PropertyCategory> all = [
    PropertyCategory(
      label: 'All',
      icon: Icons.grid_view_rounded,
      matchingTypes: [],
    ),
    PropertyCategory(
      label: 'House',
      icon: Icons.home_rounded,
      matchingTypes: ['house', 'upper_portion', 'lower_portion', 'farm_house'],
    ),
    PropertyCategory(
      label: 'Apartment',
      icon: Icons.apartment_rounded,
      matchingTypes: ['apartment', 'flat', 'penthouse', 'room'],
    ),
    PropertyCategory(
      label: 'Plot',
      icon: Icons.landscape_rounded,
      matchingTypes: [
        'plot',
        'residential_plot',
        'commercial_plot',
        'agricultural_land',
        'industrial_land',
        'plot_file',
        'plot_form',
      ],
    ),
    PropertyCategory(
      label: 'Commercial',
      icon: Icons.storefront_rounded,
      matchingTypes: [
        'commercial',
        'commercial_plot',
        'office',
        'shop',
        'warehouse',
        'factory',
        'building',
      ],
    ),
  ];
}
