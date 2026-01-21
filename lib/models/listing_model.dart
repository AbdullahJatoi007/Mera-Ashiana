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
    return Listing(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      city: json['city'],
      // Note: Backend uses 'approval_status' in the DB/JSON response
      status: json['approval_status'] ?? 'pending',
      area: json['area']?.toString(),
      bedrooms: int.tryParse(json['bedrooms'].toString()) ?? 0,
      bathrooms: int.tryParse(json['bathrooms'].toString()) ?? 0,
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }
}
