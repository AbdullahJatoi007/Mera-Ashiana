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
    // These heights ensure enough room for the title and buttons
    const double minHeaderHeight = 70.0;
    const double maxHeaderHeight = 260.0;

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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Opacity fades out text as the search bar moves up
    final double opacity = (1.0 - progress * 2.5).clamp(0.0, 1.0);
    final double searchBarAreaHeight = minHeight - statusBarHeight;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: progress < 1
            ? const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )
            : BorderRadius.zero,
      ),
      child: Stack(
        children: [
          // 1. COLLAPSING CONTENT
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            bottom: searchBarAreaHeight,
            child: ClipRect(
              // ClipRect cuts off the overflow content so it stays hidden
              child: Opacity(
                opacity: opacity,
                child: OverflowBox(
                  // OverflowBox allows the content to stay at max size
                  // even when the header is shrinking
                  minHeight: 0,
                  maxHeight: maxExtent - minHeight,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _CollapsingContent(
                      selectedOption: selectedOption,
                      onOptionSelected: onOptionSelected,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. PERSISTENT SEARCH BAR
          Align(
            alignment: Alignment.bottomCenter,
            child: _PersistentSearchBar(height: searchBarAreaHeight),
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
    required this.onOptionSelected
  });

  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Critical to avoid pushing content
      children: [
        const Text(
          'Hi there, what are you looking for?',
          style: TextStyle(color: AppColors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        const Text(
          'Find Your Home.',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _ToggleButton(
                    label: 'BUY',
                    isSelected: selectedOption == 'BUY',
                    onPressed: onOptionSelected
                )
            ),
            const SizedBox(width: 12),
            Expanded(
                child: _ToggleButton(
                    label: 'RENT',
                    isSelected: selectedOption == 'RENT',
                    onPressed: onOptionSelected
                )
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
      color: Colors.transparent,
      child: Center(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search properties...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
        foregroundColor: isSelected ? AppColors.primaryNavy : AppColors.accentYellow,
        side: const BorderSide(color: AppColors.accentYellow),
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}