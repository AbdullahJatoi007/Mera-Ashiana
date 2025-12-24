import 'package:flutter/material.dart';
import 'package:mera_ashiana/theme/app_colors.dart';

class RealEstateRegistrationScreen extends StatefulWidget {
  const RealEstateRegistrationScreen({super.key});

  @override
  State<RealEstateRegistrationScreen> createState() =>
      _RealEstateRegistrationScreenState();
}

class _RealEstateRegistrationScreenState
    extends State<RealEstateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _agencyType = 'Agency'; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Partner Registration",
          style: TextStyle(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
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
              _buildProgressHeader(),
              const SizedBox(height: 30),

              // 1. Profile Photo / Logo
              _buildLogoSection(),
              const SizedBox(height: 30),

              // 2. Business Type Selector
              _buildSectionTitle("I am a..."),
              _buildTypeSelector(),
              const SizedBox(height: 25),

              // 3. Basic Information
              _buildSectionTitle("Business Details"),
              _buildTextField(
                label: "Agency / Company Name",
                icon: Icons.business,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: "CEO / Principal Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: "NTN / Sales Tax Number",
                icon: Icons.assignment_ind_outlined,
                hint: "1234567-8",
              ),
              const SizedBox(height: 25),

              // 4. Contact & Location
              _buildSectionTitle("Contact Information"),
              _buildTextField(
                label: "Mobile Number",
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: "Email Address",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: "City / Service Areas",
                icon: Icons.map_outlined,
                hint: "e.g., DHA, Bahria, Clifton",
              ),
              const SizedBox(height: 25),

              // 5. Document Upload Section (UI Placeholder)
              _buildSectionTitle("Legal Documents (CNIC / License)"),
              _buildUploadPlaceholder("Upload FBR/NTN Certificate"),
              const SizedBox(height: 10),
              _buildUploadPlaceholder("Upload CNIC (Front & Back)"),
              const SizedBox(height: 30),

              // 6. Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Logic to save data
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "SUBMIT FOR VERIFICATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

  // --- HELPER COMPONENTS ---

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryNavy, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Your details will be verified by our team within 24-48 hours.",
              style: TextStyle(fontSize: 12, color: AppColors.primaryNavy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.grey.shade100,
            child: const Icon(
              Icons.add_business_outlined,
              size: 40,
              color: AppColors.textGrey,
            ),
          ),
          TextButton(onPressed: () {}, child: const Text("Upload Agency Logo")),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _typeChip("Agency"),
        const SizedBox(width: 10),
        _typeChip("Developer"),
        const SizedBox(width: 10),
        _typeChip("Freelancer"),
      ],
    );
  }

  Widget _typeChip(String label) {
    bool isSelected = _agencyType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _agencyType = label),
      selectedColor: AppColors.accentYellow,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryNavy : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUploadPlaceholder(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.borderGrey,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryNavy),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryNavy, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }
}
