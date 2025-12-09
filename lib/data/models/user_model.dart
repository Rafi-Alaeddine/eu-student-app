// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? country;
  final String? city;
  final String? university;
  final String? imageUrl;
  final List<String> favoriteUniversities;
  final List<String> favoriteHousing;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.country,
    this.city,
    this.university,
    this.imageUrl,
    this.favoriteUniversities = const [],
    this.favoriteHousing = const [],
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      university: json['university'] as String?,
      imageUrl: json['imageUrl'] as String?,
      favoriteUniversities: json['favoriteUniversities'] != null
          ? List<String>.from(json['favoriteUniversities'] as List)
          : [],
      favoriteHousing: json['favoriteHousing'] != null
          ? List<String>.from(json['favoriteHousing'] as List)
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'city': city,
      'university': university,
      'imageUrl': imageUrl,
      'favoriteUniversities': favoriteUniversities,
      'favoriteHousing': favoriteHousing,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? country,
    String? city,
    String? university,
    String? imageUrl,
    List<String>? favoriteUniversities,
    List<String>? favoriteHousing,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      university: university ?? this.university,
      imageUrl: imageUrl ?? this.imageUrl,
      favoriteUniversities: favoriteUniversities ?? this.favoriteUniversities,
      favoriteHousing: favoriteHousing ?? this.favoriteHousing,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
