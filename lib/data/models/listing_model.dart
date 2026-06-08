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
  final String? contactEmail;
  final bool isFeatured;

  // 👇 NEW FIELD
  final String? soldStatus;
  final String? slug;

  final String? createdByName;
  final String? createdByType;
  final String? createdByPhone;
  final String? createdByEmail;

  static const String _imageBaseUrl = "https://api-staging.mera-ashiana.com/";

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    this.city,
    this.slug,
    required this.status,
    required this.images,
    this.area,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.contactPhone,
    this.contactWhatsapp,
    this.contactEmail,
    required this.isFeatured,
    this.soldStatus,
    this.createdByName,
    this.createdByType,
    this.createdByPhone,
    this.createdByEmail,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    String? name;
    String? ownerType;
    String? ownerPhone;
    String? ownerEmail;

    if (json['users'] != null) {
      final u = json['users'];
      name = u['username'] ?? u['name'];
      ownerPhone = u['phone'];
      ownerEmail = u['email'];
      ownerType = "user";
    } else if (json['agencies'] != null) {
      final a = json['agencies'];
      name = a['agency_name'];
      ownerPhone = a['phone'];
      ownerEmail = a['email'];
      ownerType = "agency";
    }

    final rawImages = json['listing_images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages
          .map((img) {
            final path = img['file_path']?.toString().trim() ?? '';
            if (path.isEmpty) return '';
            return path.startsWith('http') ? path : '$_imageBaseUrl$path';
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Listing(
      id: json['id'] ?? 0,
      slug: json['slug']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      location: json['location'] ?? '',
      type: json['type']?.toString().toLowerCase() ?? 'house',
      city: json['city'],
      status: (json['status'] ?? json['purpose'] ?? 'sale')
          .toString()
          .toLowerCase(),
      images: parsedImages,
      area: json['area']?.toString(),
      bedrooms: int.tryParse('${json['bedrooms'] ?? 0}') ?? 0,
      bathrooms: int.tryParse('${json['bathrooms'] ?? 0}') ?? 0,
      contactPhone: json['contact_phone']?.toString(),
      contactWhatsapp: json['contact_whatsapp']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,

      // 👇 MAPPING SOLD STATUS
      soldStatus: json['sold_status']?.toString() ?? 'available',

      createdByName: name,
      createdByType: ownerType,
      createdByPhone: ownerPhone,
      createdByEmail: ownerEmail,
    );
  }
}
