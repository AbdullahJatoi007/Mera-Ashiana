import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../data/models/listing_model.dart';
import '../../../shared/helpers/validation_helper.dart';
import '../controllers/add_listing_controller.dart';
import '../widgets/image_picker_section.dart';
import '../widgets/listing_amenities_picker.dart';
import '../widgets/listing_dropdown.dart';
import '../widgets/listing_section.dart';
import '../widgets/listing_text_field.dart';

class AddListingScreen extends StatefulWidget {
  final Listing? listing; // null = create, non-null = edit
  const AddListingScreen({super.key, this.listing});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddListingController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = AddListingController(existingListing: widget.listing);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_controller.isEditing && _controller.selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.photoError),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _controller.submit();
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.isEditing ? "Listing updated!" : "Listing posted!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Operation failed"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yellow = isDark ? AppDarkColors.accentYellow : AppColors.accentYellow;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      appBar: AppBar(
        title: Text(
          _controller.isEditing ? 'Edit Property' : loc.postProperty,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primaryNavy,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            ImagePickerSection(
              existingImageUrls: _controller.existingImageUrls,
              selectedImages: _controller.selectedImages,
              isDark: isDark,
              accent: yellow,
              loc: loc,
              onImagesPicked: (files) =>
                  setState(() => _controller.addImages(files)),
              onRemoveNew: (i) => setState(() => _controller.removeNewImage(i)),
              onRemoveExisting: (i) =>
                  setState(() => _controller.removeExistingImage(i)),
            ),
            const SizedBox(height: 20),

            // ── General Details ─────────────────────────
            ListingSection(
              title: loc.generalDetails,
              isDark: isDark,
              children: [
                ListingTextField(
                  controller: _controller.titleController,
                  label: loc.title,
                  icon: Icons.title,
                  isDark: isDark,
                  yellow: yellow,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? loc.requiredError
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListingDropdown(
                        label: 'Type',
                        icon: Icons.home_work_outlined,
                        value: _controller.selectedType,
                        items: AddListingController.propertyTypes,
                        onChanged: (v) =>
                            setState(() => _controller.selectedType = v!),
                        isDark: isDark,
                        yellow: yellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListingDropdown(
                        label: 'Purpose',
                        icon: Icons.sell_outlined,
                        value: _controller.selectedStatus,
                        items: AddListingController.propertyStatuses,
                        onChanged: (v) =>
                            setState(() => _controller.selectedStatus = v!),
                        isDark: isDark,
                        yellow: yellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.priceController,
                        label: loc.price,
                        icon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: AddListingController.priceFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: (v) =>
                            ValidationHelper.validateDecimalNumber(
                              v,
                              fieldLabel: loc.price,
                              max: 999999999999, // ~999 billion PKR ceiling
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.areaController,
                        label: loc.area,
                        icon: Icons.straighten,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: AddListingController.areaFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: (v) =>
                            ValidationHelper.validateDecimalNumber(
                              v,
                              fieldLabel: loc.area,
                              max: 9999999,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.bedsController,
                        label: loc.beds,
                        icon: Icons.king_bed_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters:
                            AddListingController.bedsBathsFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: (v) => ValidationHelper.validateWholeNumber(
                          v,
                          fieldLabel: loc.beds,
                          max: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.bathsController,
                        label: loc.baths,
                        icon: Icons.bathtub_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters:
                            AddListingController.bedsBathsFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: (v) => ValidationHelper.validateWholeNumber(
                          v,
                          fieldLabel: loc.baths,
                          max: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 👇 NEW: Floor / Total Floors
                Row(
                  children: [
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.floorController,
                        label: 'Floor',
                        icon: Icons.stairs_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: AddListingController.floorFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: (v) => ValidationHelper.validateWholeNumber(
                          v,
                          fieldLabel: 'Floor',
                          max: 200,
                          required: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.totalFloorsController,
                        label: 'Total Floors',
                        icon: Icons.apartment_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: AddListingController.floorFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: (v) => ValidationHelper.validateWholeNumber(
                          v,
                          fieldLabel: 'Total Floors',
                          max: 200,
                          required: false,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 👇 NEW: Parking Size / Year Built
                Row(
                  children: [
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.parkingSizeController,
                        label: 'Parking Size',
                        icon: Icons.local_parking_outlined,
                        inputFormatters:
                            AddListingController.shortTextFormatters,
                        isDark: isDark,
                        yellow: yellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.yearBuiltController,
                        label: 'Year Built',
                        icon: Icons.event_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: AddListingController.yearFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: (v) => ValidationHelper.validateYear(
                          v,
                          fieldLabel: 'Year Built',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListingTextField(
                  controller: _controller.descController,
                  label: loc.description,
                  icon: Icons.notes,
                  maxLines: 3,
                  isDark: isDark,
                  yellow: yellow,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? loc.requiredError
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Location Details ────────────────────────
            ListingSection(
              title: 'Location Details',
              isDark: isDark,
              children: [
                ListingTextField(
                  controller: _controller.locationController,
                  label: loc.location,
                  icon: Icons.place_outlined,
                  isDark: isDark,
                  yellow: yellow,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? loc.requiredError
                      : null,
                ),
                const SizedBox(height: 12),
                ListingDropdown(
                  label: 'City',
                  icon: Icons.location_city_outlined,
                  value: _controller.selectedCity ?? kOtherOptionValue,
                  items: AddListingController.majorCities
                      .map((c) => {'value': c, 'label': c})
                      .toList(),
                  enableOther: true,
                  otherController: _controller.cityOtherController,
                  onChanged: (v) =>
                      setState(() => _controller.selectedCity = v),
                  isDark: isDark,
                  yellow: yellow,
                  otherValidator: (v) =>
                      (_controller.selectedCity == kOtherOptionValue &&
                          (v == null || v.trim().isEmpty))
                      ? loc.requiredError
                      : null,
                ),
                const SizedBox(height: 12),
                ListingDropdown(
                  label: 'Province',
                  icon: Icons.map_outlined,
                  value: _controller.selectedProvince ?? kOtherOptionValue,
                  items: AddListingController.provinces
                      .map((p) => {'value': p, 'label': p})
                      .toList(),
                  enableOther: true,
                  otherController: _controller.provinceOtherController,
                  onChanged: (v) =>
                      setState(() => _controller.selectedProvince = v),
                  isDark: isDark,
                  yellow: yellow,
                  otherValidator: (v) =>
                      (_controller.selectedProvince == kOtherOptionValue &&
                          (v == null || v.trim().isEmpty))
                      ? loc.requiredError
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.neighborhoodController,
                        label: 'Neighborhood',
                        icon: Icons.holiday_village_outlined,
                        inputFormatters:
                            AddListingController.shortTextFormatters,
                        isDark: isDark,
                        yellow: yellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListingTextField(
                        controller: _controller.zipCodeController,
                        label: 'Zip Code',
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: AddListingController.zipFormatters,
                        isDark: isDark,
                        yellow: yellow,
                        validator: ValidationHelper.validateZipCode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Amenities ────────────────────────────────
            ListingSection(
              title: 'Amenities',
              isDark: isDark,
              children: [
                ListingAmenitiesPicker(
                  allAmenities: AddListingController.amenitiesList,
                  selected: _controller.selectedAmenities,
                  onAdd: (a) => setState(() => _controller.addAmenity(a)),
                  onRemove: (a) => setState(() => _controller.removeAmenity(a)),
                  isDark: isDark,
                  yellow: yellow,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Contact Information ─────────────────────
            ListingSection(
              title: loc.contactInformation,
              isDark: isDark,
              children: [
                ListingTextField(
                  controller: _controller.phoneController,
                  label: loc.phone,
                  icon: Icons.phone_iphone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: AddListingController.phoneFormatters,
                  isDark: isDark,
                  yellow: yellow,
                  validator: ValidationHelper.validatePhone,
                ),
                const SizedBox(height: 12),
                ListingTextField(
                  controller: _controller.emailController,
                  label: loc.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  yellow: yellow,
                  validator: ValidationHelper.validateEmail,
                ),
                const SizedBox(height: 12),
                // 👇 NEW: Preferred Contact Method
                ListingDropdown(
                  label: 'Preferred Contact Method',
                  icon: Icons.contact_phone_outlined,
                  value: _controller.preferredContact,
                  items: AddListingController.preferredContactOptions,
                  onChanged: (v) =>
                      setState(() => _controller.preferredContact = v!),
                  isDark: isDark,
                  yellow: yellow,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _handleSubmit(loc),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: yellow,
                foregroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : Text(
                      _controller.isEditing
                          ? 'SAVE CHANGES'
                          : loc.submitAd.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
