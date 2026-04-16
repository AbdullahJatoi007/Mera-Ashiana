class Listing {
  final int id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String type;
  final String? city;
  final String status;
  final List<String> images;
  final String? area;
  final int bedrooms;
  final int bathrooms;
  final String? contactPhone;
  final String? contactWhatsapp;
  final bool isFeatured;

  static const String _imageBaseUrl =
      "https://api-staging.mera-ashiana.com/";

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    this.city,
    required this.status,
    required this.images,
    this.area,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.contactPhone,
    this.contactWhatsapp,
    required this.isFeatured,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    final rawImages = json['listing_images'];

    List<String> parsedImages = [];

    if (rawImages is List) {
      parsedImages = rawImages.map((img) {
        final path = img['file_path']?.toString().trim() ?? '';
        if (path.isEmpty) return '';
        return path.startsWith('http')
            ? path
            : '$_imageBaseUrl$path';
      }).where((p) => p.isNotEmpty).toList();
    }

    return Listing(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      location: json['location'] ?? '',
      type: json['type']?.toString() ?? 'house',
      city: json['city'],
      status: json['status']?.toString() ?? 'sale',
      images: parsedImages,
      area: json['area']?.toString(),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      contactPhone: json['contact_phone'],
      contactWhatsapp: json['contact_whatsapp'],
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
    );
  }
}