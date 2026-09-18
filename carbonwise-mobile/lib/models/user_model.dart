class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? city;
  final String? profileImage;
  final bool isVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.city,
    this.profileImage,
    this.isVerified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreated;
    if (json['createdAt'] != null) {
      parsedCreated = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else {
      parsedCreated = DateTime.now();
    }

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'CONSUMER',
      phone: json['phone']?.toString(),
      city: json['city']?.toString(),
      profileImage: json['profileImage']?.toString(),
      isVerified: json['isVerified'] == true,
      createdAt: parsedCreated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'city': city,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

