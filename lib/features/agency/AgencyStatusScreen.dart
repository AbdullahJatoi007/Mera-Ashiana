import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import 'package:mera_ashiana/data/services/agency_service.dart';
import 'package:mera_ashiana/features/agency/agency_registration_screen.dart';
import '../../core/theme/app_colors_dark.dart';
import '../../data/models/agency_model.dart';

class AgencyStatusScreen extends StatefulWidget {
  const AgencyStatusScreen({super.key});

  @override
  State<AgencyStatusScreen> createState() => _AgencyStatusScreenState();
}

class _AgencyStatusScreenState extends State<AgencyStatusScreen> {
  late Future<Agency?> _agencyFuture;

  @override
  void initState() {
    super.initState();
    _agencyFuture = AgencyService.fetchMyAgency();
  }

  void _refresh() =>
      setState(() => _agencyFuture = AgencyService.fetchMyAgency());

  void _navigateToRegistration({Agency? agency}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RealEstateRegistrationScreen(agency: agency),
      ),
    ).then((updated) {
      if (updated == true) _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yellow = isDark ? AppDarkColors.accentYellow : AppColors.accentYellow;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Agency Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primaryNavy,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Agency?>(
        future: _agencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: yellow));
          }

          final agency = snapshot.data;
          if (agency == null) return _buildEmptyState(isDark, yellow);

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatusCard(agency),
                  const SizedBox(height: 16),
                  _buildDetailsCard(agency, isDark),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow,
                            foregroundColor: isDark
                                ? AppDarkColors.primaryNavy
                                : Colors.white,
                          ),
                          onPressed: () =>
                              _navigateToRegistration(agency: agency),
                          child: const Text(
                            "Edit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppDarkColors.errorRed
                                : AppColors.errorRed,
                          ),
                          onPressed: () async {
                            final ok = await AgencyService.deleteAgency();
                            if (ok) _refresh();
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Agency agency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          "Status: ${agency.status.toUpperCase()}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Agency agency, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final surfaceColor = isDark ? AppDarkColors.surface : Colors.white;

    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Name",
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textGrey,
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              agency.agencyName,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppDarkColors.borderGrey : AppColors.borderGrey,
          ),
          ListTile(
            title: Text(
              "Email",
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textGrey,
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              agency.email,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color yellow) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            "No agency found",
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: isDark
                  ? AppDarkColors.primaryNavy
                  : Colors.white,
            ),
            onPressed: () => _navigateToRegistration(),
            child: const Text(
              "Register Now",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
