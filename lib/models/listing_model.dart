class Listing {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String type;
  final String? city;
  final String? status;
  final List<String> images;
  final String? area;
  final int bedrooms;
  final int bathrooms;
  final String? contactEmail;
  final String? contactPhone;

  Listing({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    this.city,
    this.status,
    this.images = const [],
    this.area,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.contactEmail,
    this.contactPhone,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Helper to extract images safely
    List<String> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        parsedImages = List<String>.from(
          json['images'].map((x) => x.toString()),
        );
      }
    }

    return Listing(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      location: json['location']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      city: json['city']?.toString(),
      status: json['approval_status']?.toString() ?? 'pending',
      area: json['area']?.toString(),
      bedrooms: int.tryParse(json['bedrooms'].toString()) ?? 0,
      bathrooms: int.tryParse(json['bathrooms'].toString()) ?? 0,
      contactEmail: json['contact_email']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      images: parsedImages,
    );
  }
}
