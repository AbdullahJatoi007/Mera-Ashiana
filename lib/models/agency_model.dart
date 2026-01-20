class Agency {
  final int id;
  final String agencyName;
  final String slug;
  final String? logo;
  final String? description;
  final String? phone;
  final String email;
  final String? address;
  final int userId;
  final DateTime? createdAt;

  Agency({
    required this.id,
    required this.agencyName,
    required this.slug,
    this.logo,
    this.description,
    this.phone,
    required this.email,
    this.address,
    required this.userId,
    this.createdAt,
  });

  // Convert JSON from Backend to Agency Object
  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'],
      agencyName: json['agency_name'] ?? '',
      slug: json['slug'] ?? '',
      logo: json['logo'],
      description: json['description'],
      phone: json['phone'],
      email: json['email'] ?? '',
      address: json['address'],
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Convert Agency Object to JSON (for API updates)
  Map<String, dynamic> toJson() {
    return {
      'agency_name': agencyName,
      'slug': slug,
      'logo': logo,
      'description': description,
      'phone': phone,
      'email': email,
      'address': address,
      'user_id': userId,
    };
  }
}