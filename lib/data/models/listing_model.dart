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

  final String? soldStatus;
  final String? slug;

  final String? createdByName;
  final String? createdByType;
  final String? createdByPhone;
  final String? createdByEmail;

  // 👇 NEW: owner's avatar (users.profile_pic) or agency logo (agencies.logo)
  final String? createdByAvatar;

  // 👇 NEW: agency-only — used to link to the agency's public page
  final String? agencySlug;

  // 👇 NEW: location/coordinates
  final double? latitude;
  final double? longitude;
  final String? province;
  final String? neighborhood;
  final String? zipCode;

  // 👇 NEW: building details
  final int? floor;
  final int? totalFloors;
  final String? parkingSize;
  final int? yearBuilt;

  // 👇 NEW: media / extras
  final String? videoUrl;
  final List<String> amenities;
  final String? preferredContact;

  // 👇 NEW: engagement / moderation
  final int likesCount;
  final String? approvalStatus;

  // 👇 NEW: only present on favorites-list responses (property_likes.created_at)
  final DateTime? likedAt;

  static const String _imageBaseUrl = "https://img.mera-ashiana.com/";

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
    this.createdByAvatar,
    this.agencySlug,
    this.latitude,
    this.longitude,
    this.province,
    this.neighborhood,
    this.zipCode,
    this.floor,
    this.totalFloors,
    this.parkingSize,
    this.yearBuilt,
    this.videoUrl,
    this.amenities = const [],
    this.preferredContact,
    this.likesCount = 0,
    this.approvalStatus,
    this.likedAt,
  });

  /// Resolves a raw image path/URL from the API into a full, usable URL.
  /// Same "already absolute or needs prefixing" pattern used everywhere
  /// else in the app (User.profileImage, Agency.logo).
  static String _resolveImageUrl(String rawPath) {
    return rawPath.startsWith('http') ? rawPath : '$_imageBaseUrl$rawPath';
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    String? name;
    String? ownerType;
    String? ownerPhone;
    String? ownerEmail;
    String? ownerAvatar;
    String? agencySlug;

    if (json['users'] != null) {
      final u = json['users'];
      name = u['username'] ?? u['name'];
      ownerPhone = u['phone'];
      ownerEmail = u['email'];
      ownerType = "user";
      final rawAvatar = u['profile_pic']?.toString();
      ownerAvatar = (rawAvatar != null && rawAvatar.isNotEmpty)
          ? _resolveImageUrl(rawAvatar)
          : null;
    } else if (json['agencies'] != null) {
      final a = json['agencies'];
      name = a['agency_name'];
      ownerPhone = a['phone'];
      ownerEmail = a['email'];
      ownerType = "agency";
      agencySlug = a['slug']?.toString();
      final rawLogo = a['logo']?.toString();
      ownerAvatar = (rawLogo != null && rawLogo.isNotEmpty)
          ? _resolveImageUrl(rawLogo)
          : null;
    }

    final rawImages = json['listing_images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages
          .map((img) {
            final path = img['file_path']?.toString().trim() ?? '';
            if (path.isEmpty) return '';
            return _resolveImageUrl(path);
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // amenities comes back as a JSON array (Prisma `Json` column) —
    // defensively handle it being null, a List, or (rarely) a raw string.
    List<String> parsedAmenities = [];
    final rawAmenities = json['amenities'];
    if (rawAmenities is List) {
      parsedAmenities = rawAmenities.map((e) => e.toString()).toList();
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

      soldStatus: json['sold_status']?.toString() ?? 'available',

      createdByName: name,
      createdByType: ownerType,
      createdByPhone: ownerPhone,
      createdByEmail: ownerEmail,
      createdByAvatar: ownerAvatar,
      agencySlug: agencySlug,

      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      province: json['province']?.toString(),
      neighborhood: json['neighborhood']?.toString(),
      zipCode: json['zip_code']?.toString(),

      floor: int.tryParse(json['floor']?.toString() ?? ''),
      totalFloors: int.tryParse(json['total_floors']?.toString() ?? ''),
      parkingSize: json['parking_size']?.toString(),
      yearBuilt: int.tryParse(json['year_built']?.toString() ?? ''),

      videoUrl: json['video_url']?.toString(),
      amenities: parsedAmenities,
      preferredContact: json['preferred_contact']?.toString(),

      likesCount: int.tryParse('${json['likes_count'] ?? 0}') ?? 0,
      approvalStatus: json['approval_status']?.toString(),

      likedAt: json['liked_at'] != null
          ? DateTime.tryParse(json['liked_at'].toString())
          : null,
    );
  }
}
