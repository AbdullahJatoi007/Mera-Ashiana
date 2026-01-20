import 'dart:convert';

class Listing {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String type;
  final String? city;
  final List<String>? images;

  Listing({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    this.city,
    this.images,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      city: json['city'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }
}