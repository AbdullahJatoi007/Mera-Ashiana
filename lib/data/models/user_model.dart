class User {
  final int id;
  final String username;
  final String email;
  final String type;
  final String? phone;
  final String? profileImage; // Added field

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.type,
    this.phone,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://api.mera-ashiana.com";

    // Backend uses 'profile_pic' in the database/model
    String? rawPath = json['profile_pic'];

    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? 'user',
      phone: json['phone'],
      profileImage: (rawPath != null && rawPath.isNotEmpty)
          ? "$baseUrl$rawPath"
          : null,
    );
  }
}
