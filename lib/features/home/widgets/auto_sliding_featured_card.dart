import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';
import 'package:mera_ashiana/features/properties/screens/project_details_screen.dart';

class AutoSlidingFeaturedCard extends StatefulWidget {
  final Listing listing;
  final ThemeData theme;

  const AutoSlidingFeaturedCard({
    super.key,
    required this.listing,
    required this.theme,
  });

  @override
  State<AutoSlidingFeaturedCard> createState() =>
      _AutoSlidingFeaturedCardState();
}

class _AutoSlidingFeaturedCardState extends State<AutoSlidingFeaturedCard> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final images = widget.listing.images;

    if (images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % images.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.listing.images.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(listing: widget.listing),
        ),
      ),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: hasImages ? widget.listing.images.length : 1,
                itemBuilder: (context, i) => Image.network(
                  hasImages ? widget.listing.images[i] : '',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.home, size: 50),
                  ),
                ),
              ),

              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.listing.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "PKR ${widget.listing.price}",
                      style: TextStyle(
                        color: widget.theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
