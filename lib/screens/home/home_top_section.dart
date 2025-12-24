import 'package:flutter/material.dart';
import 'package:mera_ashiana/screens/search_filter_screen.dart';

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
    // REDUCED HEIGHT: Total 170px + Status bar
    final double minHeaderHeight = 60.0 + statusBarHeight;
    final double maxHeaderHeight = 170.0 + statusBarHeight;

    return SliverPersistentHeader(
      pinned: true,
      delegate: HomeHeaderDelegate(
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

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeHeaderDelegate({
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
    final double diff = maxExtent - minExtent;
    final double progress = (shrinkOffset / diff).clamp(0.0, 1.0);

    // Snappy fade-out: Content vanishes by the time 30% is scrolled
    final double contentOpacity = (1.0 - (progress * 3.5)).clamp(0.0, 1.0);

    return Container(
      color: primaryColor,
      child: Stack(
        children: [
          // Background with subtle rounded corners
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24 * (1 - progress)),
                bottomRight: Radius.circular(24 * (1 - progress)),
              ),
            ),
          ),

          // Collapsing Content (Ultra Slim)
          if (contentOpacity > 0.01)
            Positioned(
              top: statusBarHeight + 10,
              left: 20,
              right: 20,
              child: Opacity(
                opacity: contentOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find your home',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

          // Search Bar (Docked at the bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _SlimSearchBar(iconColor: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeHeaderDelegate old) =>
      old.selectedOption != selectedOption;
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
      height: 38, // Fixed height for a tighter look
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
    bool isSel = selectedOption == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onOptionSelected(label),
        child: Container(
          decoration: BoxDecoration(
            color: isSel ? buttonColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSel ? primaryColor : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _SlimSearchBar extends StatelessWidget {
  const _SlimSearchBar({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the search filter screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchFilterScreen()),
        );
      },
      child: Container(
        height: 42, // Slim search bar
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.search, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search properties...',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
