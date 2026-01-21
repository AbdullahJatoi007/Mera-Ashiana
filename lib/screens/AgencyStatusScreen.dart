import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/agency_model.dart';
import 'package:mera_ashiana/services/agency_service.dart';
import 'package:mera_ashiana/screens/real_estate_registration_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Agency Status"), centerTitle: true),
      body: FutureBuilder<Agency?>(
        future: _agencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState(context, theme);
          }

          final agency = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async =>
                setState(() => _agencyFuture = AgencyService.fetchMyAgency()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatusCard(agency, theme),
                  const SizedBox(height: 20),
                  _buildAgencyDetails(agency, theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 80,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Agency Registered",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RealEstateRegistrationScreen(),
                  ),
                ).then(
                  (_) => setState(
                    () => _agencyFuture = AgencyService.fetchMyAgency(),
                  ),
                ),
            child: const Text("Register Now"),
          ),
        ],
      ),
    );
  }

  // ... (Keep your _buildStatusCard and _buildAgencyDetails from the previous block)
  Widget _buildStatusCard(Agency agency, ThemeData theme) {
    Color statusColor = agency.status.toLowerCase() == 'approved'
        ? Colors.green
        : agency.status.toLowerCase() == 'rejected'
        ? Colors.red
        : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            agency.status == 'approved'
                ? Icons.check_circle
                : Icons.hourglass_top,
            color: statusColor,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            "STATUS: ${agency.status.toUpperCase()}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyDetails(Agency agency, ThemeData theme) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Name"),
            subtitle: Text(agency.agencyName),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Email"),
            subtitle: Text(agency.email),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Address"),
            subtitle: Text(agency.address ?? "N/A"),
          ),
        ],
      ),
    );
  }
}
