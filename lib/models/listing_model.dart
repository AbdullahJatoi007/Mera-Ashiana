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
  final String? createdBy;

  static const String _imageBaseUrl = "https://api-staging.mera-ashiana.com/";

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
    this.createdBy,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // 1. Improved User Data Extraction
    String? authorName;
    if (json['user'] != null) {
      // Check for common Prisma/Backend keys
      authorName =
          json['user']['username'] ??
          json['user']['full_name'] ??
          json['user']['name'];
    } else if (json['agent'] != null) {
      authorName = json['agent']['username'] ?? json['agent']['name'];
    } else if (json['username'] != null) {
      // In case the backend flattened the response
      authorName = json['username'].toString();
    }

    // 2. Image Parsing Logic
    final rawImages = json['listing_images'];
    List<String> parsedImages = [];

    if (rawImages is List) {
      parsedImages = rawImages
          .map((img) {
            final path = img['file_path']?.toString().trim() ?? '';
            if (path.isEmpty) return '';
            return path.startsWith('http') ? path : '$_imageBaseUrl$path';
          })
          .where((p) => p.isNotEmpty)
          .toList();
    }

    // 3. Robust Property Parsing
    return Listing(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      location: json['location'] ?? '',
      type: json['type']?.toString() ?? 'house',
      city: json['city'],
      status: json['status']?.toString() ?? 'sale',
      images: parsedImages,
      area: json['area']?.toString(),
      bedrooms: int.tryParse(json['bedrooms']?.toString() ?? '0') ?? 0,
      bathrooms: int.tryParse(json['bathrooms']?.toString() ?? '0') ?? 0,
      contactPhone: json['contact_phone']?.toString(),
      contactWhatsapp: json['contact_whatsapp']?.toString(),
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      createdBy: authorName,
    );
  }
}
