// lib/data/models/housing_model.dart
class HousingModel {
  final String id;
  final String title;
  final String type; // Dormitory, Apartment, Studio, Shared
  final String city;
  final String address;
  final double distanceFromCampus; // in km
  final double pricePerMonth;
  final double deposit;
  final double utilities;
  final int numberOfRooms;
  final int numberOfBathrooms;
  final double areaInSquareMeters;
  final String description;
  final List<String> amenities;
  final List<String> imageUrls;
  final LandlordInfo landlord;
  final bool isFavorite;
  final bool isAvailable;
  final DateTime availableFrom;

  HousingModel({
    required this.id,
    required this.title,
    required this.type,
    required this.city,
    required this.address,
    required this.distanceFromCampus,
    required this.pricePerMonth,
    required this.deposit,
    required this.utilities,
    required this.numberOfRooms,
    required this.numberOfBathrooms,
    required this.areaInSquareMeters,
    required this.description,
    required this.amenities,
    this.imageUrls = const [],
    required this.landlord,
    this.isFavorite = false,
    this.isAvailable = true,
    required this.availableFrom,
  });

  factory HousingModel.fromJson(Map<String, dynamic> json) {
    return HousingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      distanceFromCampus: (json['distanceFromCampus'] as num).toDouble(),
      pricePerMonth: (json['pricePerMonth'] as num).toDouble(),
      deposit: (json['deposit'] as num).toDouble(),
      utilities: (json['utilities'] as num).toDouble(),
      numberOfRooms: json['numberOfRooms'] as int,
      numberOfBathrooms: json['numberOfBathrooms'] as int,
      areaInSquareMeters: (json['areaInSquareMeters'] as num).toDouble(),
      description: json['description'] as String,
      amenities: List<String>.from(json['amenities'] as List),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'] as List)
          : [],
      landlord: LandlordInfo.fromJson(json['landlord'] as Map<String, dynamic>),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      availableFrom: DateTime.parse(json['availableFrom'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'city': city,
      'address': address,
      'distanceFromCampus': distanceFromCampus,
      'pricePerMonth': pricePerMonth,
      'deposit': deposit,
      'utilities': utilities,
      'numberOfRooms': numberOfRooms,
      'numberOfBathrooms': numberOfBathrooms,
      'areaInSquareMeters': areaInSquareMeters,
      'description': description,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'landlord': landlord.toJson(),
      'isFavorite': isFavorite,
      'isAvailable': isAvailable,
      'availableFrom': availableFrom.toIso8601String(),
    };
  }

  HousingModel copyWith({
    String? id,
    String? title,
    String? type,
    String? city,
    String? address,
    double? distanceFromCampus,
    double? pricePerMonth,
    double? deposit,
    double? utilities,
    int? numberOfRooms,
    int? numberOfBathrooms,
    double? areaInSquareMeters,
    String? description,
    List<String>? amenities,
    List<String>? imageUrls,
    LandlordInfo? landlord,
    bool? isFavorite,
    bool? isAvailable,
    DateTime? availableFrom,
  }) {
    return HousingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      city: city ?? this.city,
      address: address ?? this.address,
      distanceFromCampus: distanceFromCampus ?? this.distanceFromCampus,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      deposit: deposit ?? this.deposit,
      utilities: utilities ?? this.utilities,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      numberOfBathrooms: numberOfBathrooms ?? this.numberOfBathrooms,
      areaInSquareMeters: areaInSquareMeters ?? this.areaInSquareMeters,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      landlord: landlord ?? this.landlord,
      isFavorite: isFavorite ?? this.isFavorite,
      isAvailable: isAvailable ?? this.isAvailable,
      availableFrom: availableFrom ?? this.availableFrom,
    );
  }
}

class LandlordInfo {
  final String name;
  final String phone;
  final String email;
  final String? imageUrl;

  LandlordInfo({
    required this.name,
    required this.phone,
    required this.email,
    this.imageUrl,
  });

  factory LandlordInfo.fromJson(Map<String, dynamic> json) {
    return LandlordInfo(
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone, 'email': email, 'imageUrl': imageUrl};
  }
}
