import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/services/listing_service.dart';
import '../widgets/listing_dropdown.dart';

/// Holds all form controllers and mutable state for the Add/Edit Listing
/// screen, plus the submit logic. The screen owns an instance of this,
/// calls its mutator methods, and wraps them in setState.
class AddListingController {
  final Listing? existingListing;

  AddListingController({this.existingListing}) {
    final l = existingListing;
    if (l != null) {
      titleController.text = l.title;
      priceController.text = l.price.toStringAsFixed(0);
      locationController.text = l.location;
      descController.text = l.description;
      phoneController.text = l.contactPhone ?? '';
      emailController.text = l.contactEmail ?? '';
      areaController.text = l.area ?? '';
      bedsController.text = l.bedrooms.toString();
      bathsController.text = l.bathrooms.toString();
      selectedType = l.type;
      selectedStatus = l.status;
      existingImageUrls = List<String>.from(l.images);

      neighborhoodController.text = l.neighborhood ?? '';
      zipCodeController.text = l.zipCode ?? '';
      floorController.text = l.floor?.toString() ?? '';
      totalFloorsController.text = l.totalFloors?.toString() ?? '';
      parkingSizeController.text = l.parkingSize ?? '';
      yearBuiltController.text = l.yearBuilt?.toString() ?? '';
      selectedAmenities = List<String>.from(l.amenities);
      preferredContact = l.preferredContact ?? 'phone';

      // City/Province: if the saved value matches one of our preset
      // options, select it directly. Otherwise fall back to "Other" and
      // pre-fill the manual-entry field with whatever was saved.
      if (l.city != null && l.city!.isNotEmpty) {
        if (majorCities.contains(l.city)) {
          selectedCity = l.city;
        } else {
          selectedCity = kOtherOptionValue;
          cityOtherController.text = l.city!;
        }
      }
      if (l.province != null && l.province!.isNotEmpty) {
        if (provinces.contains(l.province)) {
          selectedProvince = l.province;
        } else {
          selectedProvince = kOtherOptionValue;
          provinceOtherController.text = l.province!;
        }
      }
    }
  }

  bool get isEditing => existingListing != null;

  // ── Text controllers ─────────────────────────────
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController(); // detailed address
  final descController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final areaController = TextEditingController();
  final bedsController = TextEditingController();
  final bathsController = TextEditingController();

  // 👇 NEW: additional detail controllers
  final neighborhoodController = TextEditingController();
  final zipCodeController = TextEditingController();
  final floorController = TextEditingController();
  final totalFloorsController = TextEditingController();
  final parkingSizeController = TextEditingController();
  final yearBuiltController = TextEditingController();
  final cityOtherController = TextEditingController();
  final provinceOtherController = TextEditingController();

  // ── Dropdown state ───────────────────────────────
  String selectedType = 'house';
  String selectedStatus = 'sale';

  // 👇 NEW: City / Province — either one of the preset options below, or
  // kOtherOptionValue (in which case the *Other controllers hold the value)
  String? selectedCity = majorCities.first;
  String? selectedProvince = provinces.first;

  // 👇 NEW: amenities the user has picked
  List<String> selectedAmenities = [];

  // 👇 NEW: preferred contact method
  String preferredContact = 'phone';

  static const propertyTypes = [
    {'value': 'house', 'label': 'House'},
    {'value': 'apartment', 'label': 'Apartment'},
    {'value': 'plot', 'label': 'Plot'},
    {'value': 'commercial', 'label': 'Commercial'},
    {'value': 'other', 'label': 'Other'},
  ];

  static const propertyStatuses = [
    {'value': 'sale', 'label': 'For Sale'},
    {'value': 'rent', 'label': 'For Rent'},
  ];

  static const preferredContactOptions = [
    {'value': 'phone', 'label': 'Phone Call'},
    {'value': 'whatsapp', 'label': 'WhatsApp'},
    {'value': 'email', 'label': 'Email'},
  ];

  // 👇 NEW: major Pakistani cities shown in the City dropdown, plus
  // "Other" (added automatically by ListingDropdownWithOther).
  // Adjust/reorder to match whatever the website's own list uses.
  static const List<String> majorCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Hyderabad',
    'Gujranwala',
    'Sialkot',
    'Sargodha',
    'Bahawalpur',
    'Sukkur',
    'Larkana',
    'Abbottabad',
    'Gwadar',
    'Mardan',
  ];

  // 👇 NEW: Pakistani provinces/territories shown in the Province dropdown.
  static const List<String> provinces = [
    'Sindh',
    'Punjab',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];

  // 👇 NEW: predefined amenities shown in the Amenities picker.
  static const List<String> amenitiesList = [
    'Parking',
    'Lift/Elevator',
    'Security Guard',
    'Backup Generator',
    'Gas Connection',
    'Water Supply',
    'Internet/Wifi',
    'Air Conditioning',
    'Furnished',
    'Swimming Pool',
    'Gym',
    'Garden/Lawn',
    'Servant Quarters',
    'Store Room',
    'Balcony',
    'CCTV Cameras',
    'Intercom',
    'Maintenance Staff',
  ];

  void addAmenity(String amenity) {
    if (!selectedAmenities.contains(amenity)) {
      selectedAmenities.add(amenity);
    }
  }

  void removeAmenity(String amenity) => selectedAmenities.remove(amenity);

  // ── Image state ───────────────────────────────────
  final List<File> selectedImages = [];
  List<String> existingImageUrls = [];
  final List<int> keepImageIds = [];

  void addImages(List<File> newFiles) => selectedImages.addAll(newFiles);

  void removeNewImage(int index) => selectedImages.removeAt(index);

  void removeExistingImage(int index) => existingImageUrls.removeAt(index);

  void dispose() {
    for (final c in [
      titleController,
      priceController,
      locationController,
      descController,
      phoneController,
      emailController,
      areaController,
      bedsController,
      bathsController,
      neighborhoodController,
      zipCodeController,
      floorController,
      totalFloorsController,
      parkingSizeController,
      yearBuiltController,
      cityOtherController,
      provinceOtherController,
    ]) {
      c.dispose();
    }
  }

  // ── Input formatters ─────────────────────────────
  // Flutter-specific TextInputFormatters — block invalid keystrokes
  // (wrong characters + excessive length) as a first line of defense
  // alongside the max-value checks in ValidationHelper.

  static final bedsBathsFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(2),
  ];

  static final priceFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    LengthLimitingTextInputFormatter(12),
  ];

  static final areaFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    LengthLimitingTextInputFormatter(7),
  ];

  static final phoneFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
    LengthLimitingTextInputFormatter(13),
  ];

  // 👇 NEW: floor / total floors — small whole numbers.
  static final floorFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(3),
  ];

  // 👇 NEW: year built — exactly 4 digits.
  static final yearFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(4),
  ];

  // 👇 NEW: zip code — exactly 5 digits.
  static final zipFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(5),
  ];

  // 👇 NEW: free-text fields with a generous but sane length cap.
  static final shortTextFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(60),
  ];

  // Resolves the effective City/Province value: the preset selection, or
  // whatever was typed manually if "Other" was chosen.
  String get effectiveCity => selectedCity == kOtherOptionValue
      ? cityOtherController.text.trim()
      : (selectedCity ?? '');

  String get effectiveProvince => selectedProvince == kOtherOptionValue
      ? provinceOtherController.text.trim()
      : (selectedProvince ?? '');

  // ── Submit ────────────────────────────────────────
  Future<Map<String, dynamic>> submit() async {
    final data = {
      "title": titleController.text.trim(),
      "price": priceController.text.trim(),
      "location": locationController.text.trim(),
      "description": descController.text.trim(),
      "contact_phone": phoneController.text.trim(),
      "contact_email": emailController.text.trim(),
      "area": areaController.text.trim(),
      "bedrooms": bedsController.text.trim(),
      "bathrooms": bathsController.text.trim(),
      "type": selectedType,
      "status": selectedStatus,

      // 👇 NEW fields
      "city": effectiveCity,
      "province": effectiveProvince,
      "neighborhood": neighborhoodController.text.trim(),
      "zip_code": zipCodeController.text.trim(),
      "floor": floorController.text.trim(),
      "total_floors": totalFloorsController.text.trim(),
      "parking_size": parkingSizeController.text.trim(),
      "year_built": yearBuiltController.text.trim(),
      "preferred_contact": preferredContact,
      // Sent as a JSON string, same pattern already used for
      // keep_existing_image_ids — parse server-side into the Json column.
      "amenities": jsonEncode(selectedAmenities),
    };

    if (isEditing) {
      return ListingService.updateListing(
        id: existingListing!.id,
        data: data,
        newImageFiles: selectedImages,
        keepExistingImageIds: keepImageIds,
      );
    } else {
      return ListingService.createListing(
        data: data,
        imageFiles: selectedImages,
      );
    }
  }
}
