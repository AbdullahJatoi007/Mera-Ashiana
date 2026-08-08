import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/property_type.dart';

/// A tappable field that opens a bottom-sheet list of all property types
/// (backed by [PropertyType.all]) and reports the selected raw value back
/// via [onChanged]. `null` represents "Any" (no type filter).
class PropertyTypeField extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const PropertyTypeField({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  /// Opens the type picker sheet standalone — usable from any button/icon
  /// without needing to embed the full [PropertyTypeField] widget in a
  /// layout. Returns `changed: false` if the sheet was dismissed (closed
  /// via the X or tapping outside) without picking anything, so callers
  /// can tell that apart from the user explicitly picking "Any" (which
  /// comes back as `value: null, changed: true`).
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
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
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
                          "Property Type",
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
                          onPressed: () =>
                              Navigator.pop(sheetContext, dismissedSentinel),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: PropertyType.all.length + 1, // +1 for "Any"
                      itemBuilder: (_, index) {
                        final bool isAny = index == 0;
                        final PropertyType? type = isAny
                            ? null
                            : PropertyType.all[index - 1];
                        final String label = isAny ? "Any" : type!.label;
                        final bool isSelected = isAny
                            ? selectedValue == null
                            : selectedValue == type!.value;

                        return ListTile(
                          title: Text(
                            label,
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
                          onTap: () => Navigator.pop(
                            sheetContext,
                            isAny ? null : type!.value,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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

  Future<void> _openPicker(BuildContext context) async {
    final result = await showPicker(context, selectedValue: selectedValue);
    if (result.changed) onChanged(result.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return InkWell(
      onTap: () => _openPicker(context),
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
              Icons.home_work_outlined,
              color: textColor.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                PropertyType.labelFor(selectedValue),
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
