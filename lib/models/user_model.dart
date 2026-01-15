class User {
  final int id;
  final String username;
  final String email;
  final String type;
  final String? phone;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.type,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      type: json['type'],
      phone: json['phone'],
    );
  }
}
