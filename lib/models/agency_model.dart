class Agency {
  final int id;
  final String agencyName;
  final String? logo;
  final String? description;
  final String? phone;
  final String email;
  final String? address;
  final String status;
  final int userId;
  final DateTime? createdAt;

  Agency({
    required this.id,
    required this.agencyName,
    this.logo,
    this.description,
    this.phone,
    required this.email,
    this.address,
    required this.status,
    required this.userId,
    this.createdAt,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] ?? 0,
      agencyName: json['agency_name'] ?? '',
      logo: json['logo'],
      description: json['description'],
      phone: json['phone'],
      email: json['email'] ?? '',
      address: json['address'],
      status: json['status'] ?? 'pending',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
