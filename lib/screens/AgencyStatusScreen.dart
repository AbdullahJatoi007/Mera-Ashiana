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

  void _refresh() =>
      setState(() => _agencyFuture = AgencyService.fetchMyAgency());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Agency Management"), centerTitle: true),
      body: FutureBuilder<Agency?>(
        future: _agencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If No Agency exists in DB, show Registration
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState(context, theme);
          }

          // If Agency exists, show Status and Details
          final agency = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
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

  Widget _buildStatusCard(Agency agency, ThemeData theme) {
    final status = agency.status.toLowerCase();
    Color color = status == 'approved' ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            status == 'approved' ? Icons.check_circle : Icons.hourglass_empty,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            status == 'pending'
                ? "UNDER REVIEW"
                : "STATUS: ${status.toUpperCase()}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RealEstateRegistrationScreen(),
          ),
        ).then((_) => _refresh()), // Refresh after registration
        child: const Text("Register My Agency"),
      ),
    );
  }

  Widget _buildAgencyDetails(Agency agency, ThemeData theme) {
    return Card(
      child: ListTile(
        title: Text(agency.agencyName),
        subtitle: Text(agency.email),
      ),
    );
  }
}
