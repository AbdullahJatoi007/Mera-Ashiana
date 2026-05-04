import 'package:flutter/material.dart';

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

  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);

  @override
  Widget build(BuildContext context) {
    // Max height: status bar + content area
    final double maxHeaderHeight = 95.0 + statusBarHeight;
    final double minHeaderHeight = statusBarHeight;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeHeaderDelegate(
        minHeight: minHeaderHeight,
        maxHeight: maxHeaderHeight,
        statusBarHeight: statusBarHeight,
        selectedOption: selectedOption,
        onOptionSelected: onOptionSelected,
        primaryColor: primaryNavy,
        buttonColor: accentYellow,
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.statusBarHeight,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.primaryColor,
    required this.buttonColor,
  });

  final double minHeight;
  final double maxHeight;
  final double statusBarHeight;
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;
  final Color primaryColor;
  final Color buttonColor;

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
    final double collapsibleRange = (maxExtent - minExtent).clamp(
      1.0,
      double.infinity,
    );

    // Progress: 0.0 (open) → 1.0 (collapsed)
    final double progress = (shrinkOffset / collapsibleRange).clamp(0.0, 1.0);

    // Background opacity for the lower content area only
    final double bgOpacity = (1.0 - progress).clamp(0.0, 1.0);

    // Content fades out completely by 65% scroll
    final double contentOpacity = (1.0 - (progress / 0.65)).clamp(0.0, 1.0);

    final double translateY = progress * -16.0;
    final double radius = 24.0 * (1.0 - progress);

    return ClipRect(
      child: SizedBox.expand(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // FIX 1: Solid background for Status Bar area
            // Ye hamesha solid rahega taake icons/time ke peeche white background na aaye
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: statusBarHeight,
              child: ColoredBox(color: primaryColor),
            ),

            // FIX 2: Fading background for the main content area
            // Ye statusBarHeight ke niche se start hota hai aur collapse hone par fade ho jata hai
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: bgOpacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                ),
              ),
            ),

            // Collapsible content (Text & Toggle)
            if (contentOpacity > 0)
              Positioned(
                top: statusBarHeight + 8.0,
                left: 20.0,
                right: 20.0,
                bottom: 0,
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxHeight: 95.0,
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Transform.translate(
                      offset: Offset(0, translateY),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Find your home',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _SlimToggle(
                            selectedOption: selectedOption,
                            onOptionSelected: onOptionSelected,
                            buttonColor: buttonColor,
                            primaryColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return oldDelegate.selectedOption != selectedOption ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.statusBarHeight != statusBarHeight;
  }
}

class _SlimToggle extends StatelessWidget {
  const _SlimToggle({
    required this.selectedOption,
    required this.onOptionSelected,
    required this.buttonColor,
    required this.primaryColor,
  });

  final String selectedOption;
  final ValueChanged<String> onOptionSelected;
  final Color buttonColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildItem('BUY'),
          const SizedBox(width: 4),
          _buildItem('RENT'),
        ],
      ),
    );
  }

  Widget _buildItem(String label) {
    final bool isSelected = selectedOption == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onOptionSelected(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? buttonColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
