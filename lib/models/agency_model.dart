class Agency {
  final int id;
  final String agencyName;
  final String slug;
  final String? logo;
  final String? description;
  final String? phone;
  final String email;
  final String? address;
  final String status; // <--- ADDED THIS
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
    required this.status, // <--- ADDED THIS
    required this.userId,
    this.createdAt,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] ?? 0,
      agencyName: json['agency_name'] ?? '',
      slug: json['slug'] ?? '',
      logo: json['logo'],
      description: json['description'],
      phone: json['phone'],
      email: json['email'] ?? '',
      address: json['address'],
      status: json['status'] ?? 'pending',
      // <--- ADDED THIS
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
