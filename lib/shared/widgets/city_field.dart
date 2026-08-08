import 'package:flutter/material.dart';

/// Reusable city picker: search box + "Any City" + scrollable list, opened
/// as a bottom sheet. Unlike PropertyType, city is NOT a backend enum —
/// `listings.city` is a free-text VARCHAR — so besides the curated list,
/// typing something not in the list offers it as its own selectable
/// "Search '<text>'" row instead of being blocked.
class CityField extends StatelessWidget {
  final String? selectedValue; // null = "Any City"
  final ValueChanged<String?> onChanged;

  const CityField({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  static const List<String> _allCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Peshawar',
    'Faisalabad',
    'Multan',
    'Hyderabad',
    'Quetta',
    'Sialkot',
    'Gujranwala',
    'Sargodha',
    'Bahawalpur',
    'Sukkur',
    'Larkana',
    'Abbottabad',
    'Mardan',
    'Sahiwal',
    'Gujrat',
    'Rahim Yar Khan',
  ];

  /// Opens the picker sheet standalone. Returns `changed: false` if
  /// dismissed without a pick, distinguishing that from explicitly
  /// choosing "Any City" (which returns `value: null, changed: true`).
  static Future<({String? value, bool changed})> showPicker(
    BuildContext context, {
    required String? selectedValue,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Object dismissedSentinel = Object();

    final Object? result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final String query = searchController.text.trim().toLowerCase();
            final List<String> filtered = query.isEmpty
                ? _allCities
                : _allCities
                      .where((c) => c.toLowerCase().contains(query))
                      .toList();

            // Offer the typed text itself as a pickable option when it
            // isn't already an exact match in the curated list — keeps
            // the free-text nature of the backend field usable.
            final bool showCustomOption =
                query.isNotEmpty &&
                !_allCities.any((c) => c.toLowerCase() == query);

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "City",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.onSurface,
                              ),
                              onPressed: () => Navigator.pop(
                                sheetContext,
                                dismissedSentinel,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (_) => setSheetState(() {}),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: "Search city...",
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
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
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            if (query.isEmpty)
                              ListTile(
                                leading: Icon(
                                  Icons.public_rounded,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                title: Text(
                                  "Any City",
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: selectedValue == null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: selectedValue == null
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: theme.colorScheme.secondary,
                                      )
                                    : null,
                                onTap: () => Navigator.pop(sheetContext, null),
                              ),
                            if (showCustomOption)
                              ListTile(
                                leading: const Icon(
                                  Icons.add_location_alt_outlined,
                                ),
                                title: Text(
                                  'Search "${searchController.text.trim()}"',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                onTap: () => Navigator.pop(
                                  sheetContext,
                                  searchController.text.trim(),
                                ),
                              ),
                            ...filtered.map((city) {
                              final bool isSelected = selectedValue == city;
                              return ListTile(
                                title: Text(
                                  city,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: theme.colorScheme.secondary,
                                      )
                                    : null,
                                onTap: () => Navigator.pop(sheetContext, city),
                              );
                            }),
                            if (filtered.isEmpty && !showCustomOption)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  "No matching cities",
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (identical(result, dismissedSentinel)) {
      return (value: selectedValue, changed: false);
    }
    return (value: result as String?, changed: true);
  }

  Future<void> _open(BuildContext context) async {
    final result = await showPicker(context, selectedValue: selectedValue);
    if (result.changed) onChanged(result.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_city_rounded,
              color: textColor.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedValue ?? "Any City",
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: selectedValue != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: textColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
