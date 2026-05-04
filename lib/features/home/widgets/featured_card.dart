import 'package:flutter/material.dart';
import 'package:mera_ashiana/data/models/listing_model.dart';

import 'auto_sliding_featured_card.dart';

class FeaturedProjects extends StatelessWidget {
  final List<Listing> listings;
  final ThemeData theme;

  const FeaturedProjects({
    super.key,
    required this.listings,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final featured = listings.where((l) => l.isFeatured).toList();

    if (featured.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featured.length,
        itemBuilder: (context, index) =>
            AutoSlidingFeaturedCard(listing: featured[index], theme: theme),
      ),
    );
  }
}
