class CountryModel {
  final String countryCode; // "FR", "GB", "IT"
  final String countryName; // "France", "United Kingdom", "Italy"

  CountryModel({required this.countryCode, required this.countryName});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      countryCode: json['country'] as String,
      countryName: json['countryName'] as String,
    );
  }
}
