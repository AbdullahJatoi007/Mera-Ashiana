import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(theme),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(theme),
                      const SizedBox(height: 20),

                      _buildQuickSpecsBox(theme),
                      const SizedBox(height: 30),

                      _buildSectionTitle(theme, "Main Features"),
                      _buildFeatureGrid(theme, [
                        {
                          "icon": Icons.home_work_outlined,
                          "label": "Built in 2024",
                        },
                        {"icon": Icons.layers, "label": "3 Floors"},
                        {
                          "icon": Icons.ac_unit,
                          "label": "Central Air Conditioning",
                        },
                        {"icon": Icons.elevator, "label": "Elevator/Lift"},
                      ]),
                      const SizedBox(height: 30),

                      _buildSectionTitle(theme, "Plot Features"),
                      _buildFeatureGrid(theme, [
                        {"icon": Icons.park_outlined, "label": "Park Facing"},
                        {
                          "icon": Icons.grid_view_outlined,
                          "label": "Boundary Wall",
                        },
                        {
                          "icon": Icons.electric_bolt_outlined,
                          "label": "Underground Electricity",
                        },
                      ]),
                      const SizedBox(height: 30),

                      _buildSectionTitle(theme, "Communication"),
                      _buildFeatureGrid(theme, [
                        {"icon": Icons.wifi, "label": "Broadband Internet"},
                        {"icon": Icons.tv, "label": "Satellite/Cable Ready"},
                        {
                          "icon": Icons.business_center_outlined,
                          "label": "Business Lounge",
                        },
                      ]),
                      const SizedBox(height: 30),

                      _buildSectionTitle(theme, "Nearby Facilities"),
                      _buildFeatureGrid(theme, [
                        {
                          "icon": Icons.school_outlined,
                          "label": "Nearby Schools",
                        },
                        {
                          "icon": Icons.local_hospital_outlined,
                          "label": "Nearby Hospitals",
                        },
                        {
                          "icon": Icons.mosque_outlined,
                          "label": "Nearby Mosque",
                        },
                        {
                          "icon": Icons.shopping_cart_outlined,
                          "label": "Shopping Mall",
                        },
                      ]),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomActionBar(theme),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.colorScheme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1000&q=80',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "FOR SALE",
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Icon(Icons.favorite_border, color: cs.primary),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Emaar Oceanfront - Sea View Villa",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: cs.onSurface.withOpacity(0.5),
            ),
            Text(
              " DHA Phase 8, Karachi",
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "PKR 8.5 Crore",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSpecsBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _specItem(theme, Icons.square_foot, "500", "Sq. Yd"),
          _divider(theme),
          _specItem(theme, Icons.king_bed_outlined, "4", "Beds"),
          _divider(theme),
          _specItem(theme, Icons.bathtub_outlined, "5", "Baths"),
        ],
      ),
    );
  }

  Widget _specItem(ThemeData theme, IconData icon, String value, String unit) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _divider(ThemeData theme) => Container(
    height: 35,
    width: 1,
    color: theme.dividerColor.withOpacity(0.2),
  );

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(
    ThemeData theme,
    List<Map<String, dynamic>> features,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Icon(
              features[index]['icon'],
              size: 18,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                features[index]['label'],
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActionBar(ThemeData theme) {
    final cs = theme.colorScheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.3 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message_outlined, color: Colors.green),
                label: const Text("WhatsApp"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call),
                label: const Text("Call Agent"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
