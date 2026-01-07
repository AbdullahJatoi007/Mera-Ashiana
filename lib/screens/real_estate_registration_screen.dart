import 'package:flutter/material.dart';

class RealEstateRegistrationScreen extends StatefulWidget {
  const RealEstateRegistrationScreen({super.key});

  @override
  State<RealEstateRegistrationScreen> createState() =>
      _RealEstateRegistrationScreenState();
}

class _RealEstateRegistrationScreenState
    extends State<RealEstateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _agencyType = 'Agency';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Partner Registration",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressHeader(theme),
              const SizedBox(height: 30),

              _buildLogoSection(theme),
              const SizedBox(height: 30),

              _buildSectionTitle(theme, "I am a..."),
              _buildTypeSelector(theme),
              const SizedBox(height: 25),

              _buildSectionTitle(theme, "Business Details"),
              _buildTextField(
                theme,
                label: "Agency / Company Name",
                icon: Icons.business,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                label: "CEO / Principal Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                label: "NTN / Sales Tax Number",
                icon: Icons.assignment_ind_outlined,
                hint: "1234567-8",
              ),
              const SizedBox(height: 25),

              _buildSectionTitle(theme, "Contact Information"),
              _buildTextField(
                theme,
                label: "Mobile Number",
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                label: "Email Address",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                theme,
                label: "City / Service Areas",
                icon: Icons.map_outlined,
                hint: "e.g., DHA, Bahria, Clifton",
              ),
              const SizedBox(height: 25),

              _buildSectionTitle(theme, "Legal Documents (CNIC / License)"),
              _buildUploadPlaceholder(theme, "Upload FBR/NTN Certificate"),
              const SizedBox(height: 10),
              _buildUploadPlaceholder(theme, "Upload CNIC (Front & Back)"),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      /* Submit Logic */
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "SUBMIT FOR VERIFICATION",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Your details will be verified by our team within 24-48 hours.",
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.add_business_outlined,
              size: 40,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Upload Agency Logo",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    final types = ["Agency", "Developer", "Freelancer"];
    return Wrap(
      spacing: 10,
      children: types
          .map(
            (type) => ChoiceChip(
              label: Text(type),
              selected: _agencyType == type,
              onSelected: (val) => setState(() => _agencyType = type),
              selectedColor: theme.colorScheme.secondary,
              labelStyle: TextStyle(
                color: _agencyType == type
                    ? theme.colorScheme.onSecondary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: theme.colorScheme.surface,
            ),
          )
          .toList(),
    );
  }

  Widget _buildUploadPlaceholder(ThemeData theme, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          Icon(Icons.cloud_upload_outlined, color: theme.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
