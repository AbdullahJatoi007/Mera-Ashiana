class PropertyModel {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String area;
  final String status;
  final String parkingSize;
  final int yearBuilt;
  final List<String> amenities;
  final String contactPhone;
  final String contactWhatsapp;
  final String contactEmail;
  final List<String> images;
  final int isFeatured; // NEW

  PropertyModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.status,
    required this.parkingSize,
    required this.yearBuilt,
    required this.amenities,
    required this.contactPhone,
    required this.contactWhatsapp,
    required this.contactEmail,
    required this.images,
    required this.isFeatured, // NEW
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      location: json['location'] ?? '',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: json['area'] ?? '',
      status: json['status'] ?? '',
      parkingSize: json['parking_size'] ?? '',
      yearBuilt: json['year_built'] ?? 0,
      amenities:
      (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      contactPhone: json['contact_phone'] ?? '',
      contactWhatsapp: json['contact_whatsapp'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      images: (json['images'] as List?)
          ?.map((e) => "http://api.staging.mera-ashiana.com$e")
          .toList() ??
          [],
      isFeatured: json['is_featured'] ?? 0, // NEW
    );
  }
}
