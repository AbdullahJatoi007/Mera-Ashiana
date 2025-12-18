import 'package:flutter/material.dart';
import 'package:mera_ashiana/theme/app_colors.dart';

class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.statusBarHeight,
  });

  final String selectedOption;
  final ValueChanged<String> onOptionSelected;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    // Standard heights for a professional look
    const double minHeaderHeight = 75.0;
    const double maxHeaderHeight = 280.0;

    return SliverPersistentHeader(
      pinned: true,
      delegate: HomeHeaderDelegate(
        minHeight: minHeaderHeight + statusBarHeight,
        maxHeight: maxHeaderHeight + statusBarHeight,
        statusBarHeight: statusBarHeight,
        selectedOption: selectedOption,
        onOptionSelected: onOptionSelected,
      ),
    );
  }
}

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.statusBarHeight,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  final double minHeight;
  final double maxHeight;
  final double statusBarHeight;
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double diff = maxExtent - minExtent;
    final double progress = (shrinkOffset / diff).clamp(0.0, 1.0);

    // Faster opacity fade to prevent glitchy overlap
    final double opacity = (1.0 - progress * 2.2).clamp(0.0, 1.0);
    final double searchBarHeight = minHeight - statusBarHeight;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: progress < 0.98
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              )
            : BorderRadius.zero,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. COLLAPSING CONTENT (Fixed with SingleChildScrollView to prevent RenderFlex overflow)
          if (opacity > 0.01)
            Positioned(
              top: statusBarHeight + 20,
              left: 16,
              right: 16,
              bottom: searchBarHeight,
              // Constraint to prevent overlap with search bar
              child: Opacity(
                opacity: opacity,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: _CollapsingContent(
                    selectedOption: selectedOption,
                    onOptionSelected: onOptionSelected,
                  ),
                ),
              ),
            ),

          // 2. PERSISTENT SEARCH BAR (Locks to bottom edge)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _PersistentSearchBar(height: searchBarHeight),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeHeaderDelegate old) =>
      old.selectedOption != selectedOption;
}

class _CollapsingContent extends StatelessWidget {
  const _CollapsingContent({
    required this.selectedOption,
    required this.onOptionSelected,
  });

  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Hi there, what are you looking for?',
          style: TextStyle(color: AppColors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        const Text(
          'Find Your Home.',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ToggleButton(
                label: 'BUY',
                isSelected: selectedOption == 'BUY',
                onPressed: onOptionSelected,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToggleButton(
                label: 'RENT',
                isSelected: selectedOption == 'RENT',
                onPressed: onOptionSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersistentSearchBar extends StatelessWidget {
  const _PersistentSearchBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.center,
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search properties...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textGrey,
            size: 22,
          ),
          filled: true,
          fillColor: AppColors.white,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.accentYellow : AppColors.white,
        foregroundColor: AppColors.primaryNavy,
        elevation: isSelected ? 4 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
