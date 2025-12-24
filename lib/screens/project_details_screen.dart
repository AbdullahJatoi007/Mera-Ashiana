import 'package:flutter/material.dart';
import 'package:mera_ashiana/theme/app_colors.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Image Header with Back Button
              _buildSliverAppBar(),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 20),

                      // 2. Primary Specs (Area, Beds, Baths)
                      _buildQuickSpecsBox(),
                      const SizedBox(height: 30),

                      // 3. Main Features
                      _buildSectionTitle("Main Features"),
                      _buildFeatureGrid([
                        {"icon": Icons.home_work_outlined, "label": "Built in 2024"},
                        {"icon": Icons.layers, "label": "3 Floors"},
                        {"icon": Icons.ac_unit, "label": "Central Air Conditioning"},
                        {"icon": Icons.elevator, "label": "Elevator/Lift"},
                      ]),
                      const SizedBox(height: 30),

                      // 4. Plot & Area Features
                      _buildSectionTitle("Plot Features"),
                      _buildFeatureGrid([
                        // {"icon": Icons.corner_mark, "label": "Corner Plot"},
                        {"icon": Icons.park_outlined, "label": "Park Facing"},
                        {"icon": Icons.grid_view_outlined, "label": "Boundary Wall"},
                        {"icon": Icons.electric_bolt_outlined, "label": "Underground Electricity"},
                      ]),
                      const SizedBox(height: 30),

                      // 5. Business & Communication
                      _buildSectionTitle("Communication"),
                      _buildFeatureGrid([
                        {"icon": Icons.wifi, "label": "Broadband Internet"},
                        {"icon": Icons.tv, "label": "Satellite/Cable Ready"},
                        {"icon": Icons.business_center_outlined, "label": "Business Lounge"},
                      ]),
                      const SizedBox(height: 30),

                      // 6. Community & Nearby Facilities
                      _buildSectionTitle("Nearby Facilities"),
                      _buildFeatureGrid([
                        {"icon": Icons.school_outlined, "label": "Nearby Schools"},
                        {"icon": Icons.local_hospital_outlined, "label": "Nearby Hospitals"},
                        {"icon": Icons.mosque_outlined, "label": "Nearby Mosque"},
                        {"icon": Icons.shopping_cart_outlined, "label": "Shopping Mall"},
                      ]),

                      const SizedBox(height: 120), // Bottom padding for Action Bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 7. Sticky Contact Buttons
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryNavy,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
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

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("FOR SALE",
                  style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const Icon(Icons.favorite_border, color: AppColors.primaryNavy),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Emaar Oceanfront - Sea View Villa",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        const SizedBox(height: 6),
        const Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey),
            Text(" DHA Phase 8, Karachi", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        const Text("PKR 8.5 Crore",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
      ],
    );
  }

  Widget _buildQuickSpecsBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _specItem(Icons.square_foot, "500", "Sq. Yd"),
          _divider(),
          _specItem(Icons.king_bed_outlined, "4", "Beds"),
          _divider(),
          _specItem(Icons.bathtub_outlined, "5", "Baths"),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value, String unit) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryNavy, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _divider() => Container(height: 35, width: 1, color: Colors.grey.shade300);

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
      ),
    );
  }

  Widget _buildFeatureGrid(List<Map<String, dynamic>> features) {
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
            Icon(features[index]['icon'], size: 18, color: AppColors.accentYellow),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                features[index]['label'],
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
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
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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