import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/services/listing_service.dart';

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
    }
  }

  bool get isEditing => existingListing != null;

  // ── Text controllers ─────────────────────────────
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final areaController = TextEditingController();
  final bedsController = TextEditingController();
  final bathsController = TextEditingController();

  // ── Dropdown state ───────────────────────────────
  String selectedType = 'house';
  String selectedStatus = 'sale';

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
    ]) {
      c.dispose();
    }
  }

  // ── Input formatters ─────────────────────────────
  // These stay here (rather than in ValidationHelper) since they're
  // Flutter-specific TextInputFormatters, not validation logic — they
  // block invalid *keystrokes* at input time (both wrong characters and
  // excessive length), as a first line of defense alongside the max-value
  // checks in ValidationHelper. Length caps are chosen generously — they
  // just stop absurd digit counts, the real range check happens on submit.

  // Beds / baths: no realistic listing needs more than 2 digits (max 50).
  static final bedsBathsFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(2),
  ];

  // Price (PKR): allow up to 12 digits total (covers up to ~999 billion).
  static final priceFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    LengthLimitingTextInputFormatter(12),
  ];

  // Area: allow up to 7 digits (covers up to 9,999,999 sq ft / marla / etc).
  static final areaFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    LengthLimitingTextInputFormatter(7),
  ];

  // Phone: digits and a single leading '+' only. Capped at 13 characters,
  // which covers both accepted formats —
  // 03001234567 (11 digits) and +923001234567 (13 characters incl. '+').
  static final phoneFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
    LengthLimitingTextInputFormatter(13),
  ];

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
