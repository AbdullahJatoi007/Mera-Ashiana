import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/property_model.dart';
import 'package:mera_ashiana/base_screens/widgets/auto_sliding_featured_card.dart';

class FeaturedProjects extends StatelessWidget {
  final List<PropertyModel> properties;
  final ThemeData theme;

  const FeaturedProjects({
    super.key,
    required this.properties,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final featured = properties.where((p) => p.isFeatured == 1).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featured.length,
        itemBuilder: (context, index) =>
            AutoSlidingFeaturedCard(property: featured[index], theme: theme),
      ),
    );
  }
}
