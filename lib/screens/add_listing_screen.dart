import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mera_ashiana/services/listing_service.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;
  List<File> _selectedImages = [];

  // Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _areaController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();

  String _selectedType = 'house';
  List<String> _selectedAmenities = [];

  void _submitData() async {
    if (!_formKey.currentState!.validate() || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields and add photos"),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Matches Backend/controllers/listing-controllers/listing.controller.js requiredFields
    final Map<String, dynamic> body = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "price": _priceController.text.trim(),
      "location": _locationController.text.trim(),
      "type": _selectedType,
      "bedrooms": _bedsController.text.trim(),
      "bathrooms": _bathsController.text.trim(),
      "area": _areaController.text.trim(),
      "status": "sale",
      "province": "Sindh",
      "city": "Karachi",
      "zipCode": "75600",
      "amenities": _selectedAmenities,
      // Raw List as controller handles JSON.stringify
      "contactPhone": _phoneController.text.trim(),
      "contactEmail": _emailController.text.trim(),
      "preferredContact": "phone",
    };

    final result = await ListingService.createListing(data: body);

    if (result['success']) {
      await ListingService.uploadImages(result['id'], _selectedImages);
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Property")),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Title*",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Price*",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _areaController,
                          decoration: const InputDecoration(
                            labelText: "Area (sqft)*",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bedsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Beds*",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _bathsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Baths*",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: "Location*",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description*",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone*",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email*",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue[900],
                    ),
                    child: const Text(
                      "SUBMIT AD",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, i) {
          if (i == _selectedImages.length) {
            return GestureDetector(
              onTap: () async {
                final pics = await _picker.pickMultiImage();
                setState(
                  () => _selectedImages.addAll(pics.map((e) => File(e.path))),
                );
              },
              child: Container(
                width: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.add_a_photo),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.file(
              _selectedImages[i],
              width: 100,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
