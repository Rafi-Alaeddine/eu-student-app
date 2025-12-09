// lib/data/models/university_model.dart
class UniversityModel {
  final String id;
  final String name;
  final String country;
  final String city;
  final String address;
  final int? numberOfStudents; // MADE OPTIONAL - API may not provide
  final double? rating; // MADE OPTIONAL - API may not provide
  final List<String>? programs; // MADE OPTIONAL - API may not provide
  final String description;
  final double? tuitionFeeMin; // MADE OPTIONAL - API may not provide
  final double? tuitionFeeMax; // MADE OPTIONAL - API may not provide
  final double? applicationFee; // MADE OPTIONAL - API may not provide
  final String website;
  final String? email; // MADE OPTIONAL - API may not provide
  final String? phone; // MADE OPTIONAL - API may not provide
  final List<String> imageUrls;
  final bool isFavorite;

  // NEW: HEI Detail Fields
  final String? websiteUrl; // Institution website
  final String? erasmusCode; // Erasmus charter code
  final bool? isEcheHolder; // Erasmus holder status
  final String? postalCode; // From mailing_address.postal_code
  final String? locality; // Full locality name
  final String? createdDate; // Institution creation date
  final String? officialName;

  // NEW: Additional HEI Fields from Full API
  final String? abbreviation; // Institution abbreviation
  final bool? status; // Active status
  final String? changedDate; // Last modified date
  final String? echeStartDate; // Erasmus Charter start date
  final String? echeEndDate; // Erasmus Charter end date
  final String? picCode; // PIC (Participant Identification Code)
  final String? erasmusCharterCode; // Erasmus Charter code
  final String? recipientName; // From mailing_address.recipient_name
  final String? addressLine1; // From mailing_address.address_line_1
  final String? addressLine2; // From mailing_address.address_line_2
  final String? region; // From mailing_address.region

  UniversityModel({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.address,
    this.numberOfStudents, // MADE OPTIONAL
    this.rating, // MADE OPTIONAL
    this.programs, // MADE OPTIONAL
    required this.description,
    this.tuitionFeeMin, // MADE OPTIONAL
    this.tuitionFeeMax, // MADE OPTIONAL
    this.applicationFee, // MADE OPTIONAL
    required this.website,
    this.email, // MADE OPTIONAL
    this.phone, // MADE OPTIONAL
    this.imageUrls = const [],
    this.isFavorite = false,

    this.websiteUrl,
    this.erasmusCode,
    this.isEcheHolder = false,
    this.postalCode,
    this.locality,
    this.createdDate,
    this.officialName,

    // NEW: Additional HEI Fields
    this.abbreviation,
    this.status,
    this.changedDate,
    this.echeStartDate,
    this.echeEndDate,
    this.picCode,
    this.erasmusCharterCode,
    this.recipientName,
    this.addressLine1,
    this.addressLine2,
    this.region,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      numberOfStudents: json['numberOfStudents'] as int?,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      programs: json['programs'] != null
          ? List<String>.from(json['programs'] as List)
          : null,
      description: json['description'] as String,
      tuitionFeeMin: json['tuitionFeeMin'] != null
          ? (json['tuitionFeeMin'] as num).toDouble()
          : null,
      tuitionFeeMax: json['tuitionFeeMax'] != null
          ? (json['tuitionFeeMax'] as num).toDouble()
          : null,
      applicationFee: json['applicationFee'] != null
          ? (json['applicationFee'] as num).toDouble()
          : null,
      website: json['website'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'] as List)
          : [],
      isFavorite: json['isFavorite'] as bool? ?? false,

      // HEI fields
      websiteUrl: json['websiteUrl'] as String?,
      erasmusCode: json['erasmusCode'] as String?,
      isEcheHolder: json['isEcheHolder'] as bool? ?? false,
      postalCode: json['postalCode'] as String?,
      locality: json['locality'] as String?,
      createdDate: json['createdDate'] as String?,
      officialName: json['officialName'] as String?,

      // NEW: Additional HEI fields
      abbreviation: json['abbreviation'] as String?,
      status: json['status'] as bool?,
      changedDate: json['changedDate'] as String?,
      echeStartDate: json['echeStartDate'] as String?,
      echeEndDate: json['echeEndDate'] as String?,
      picCode: json['picCode'] as String?,
      erasmusCharterCode: json['erasmusCharterCode'] as String?,
      recipientName: json['recipientName'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      region: json['region'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'city': city,
      'address': address,
      'numberOfStudents': numberOfStudents,
      'rating': rating,
      'programs': programs,
      'description': description,
      'tuitionFeeMin': tuitionFeeMin,
      'tuitionFeeMax': tuitionFeeMax,
      'applicationFee': applicationFee,
      'website': website,
      'email': email,
      'phone': phone,
      'imageUrls': imageUrls,
      'isFavorite': isFavorite,

      // HEI fields
      'websiteUrl': websiteUrl,
      'erasmusCode': erasmusCode,
      'isEcheHolder': isEcheHolder,
      'postalCode': postalCode,
      'locality': locality,
      'createdDate': createdDate,
      'officialName': officialName,

      // NEW: Additional HEI fields
      'abbreviation': abbreviation,
      'status': status,
      'changedDate': changedDate,
      'echeStartDate': echeStartDate,
      'echeEndDate': echeEndDate,
      'picCode': picCode,
      'erasmusCharterCode': erasmusCharterCode,
      'recipientName': recipientName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'region': region,
    };
  }

  UniversityModel copyWith({
    String? id,
    String? name,
    String? country,
    String? city,
    String? address,
    int? numberOfStudents,
    double? rating,
    List<String>? programs,
    String? description,
    double? tuitionFeeMin,
    double? tuitionFeeMax,
    double? applicationFee,
    String? website,
    String? email,
    String? phone,
    List<String>? imageUrls,
    bool? isFavorite,
  }) {
    return UniversityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      numberOfStudents: numberOfStudents ?? this.numberOfStudents,
      rating: rating ?? this.rating,
      programs: programs ?? this.programs,
      description: description ?? this.description,
      tuitionFeeMin: tuitionFeeMin ?? this.tuitionFeeMin,
      tuitionFeeMax: tuitionFeeMax ?? this.tuitionFeeMax,
      applicationFee: applicationFee ?? this.applicationFee,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrls: imageUrls ?? this.imageUrls,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
