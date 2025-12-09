import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../data/models/university_model.dart';
import '../core/constants/kconstants.dart';
import '../data/models/country_model.dart';

/*
API Integration Changes:
- Countries API changed from colleges-and-universities.p.rapidapi.com/api/getAllCountries to https://hei.api.uni-foundation.eu/api/public/v1/country
- No API key needed, uses Accept: application/vnd.api+json header
- Response structure: {"data": [array of countries]} instead of direct array
- Universities use HEI API: /country/{code}/hei to get institutions per country
- Cities are extracted from HEI data as Set<String> of unique cities
- University filtering by country: fetch specific country HEIs, by city: filter loaded universities
*/

class UniversityApiService {
  static const String countriesApiUrl =
      'https://hei.api.uni-foundation.eu/api/public/v1/country';
  static const String baseUrl =
      'YOUR_API_BASE_URL'; // Replace with your actual universities API URL
  static const String heisApiUrl =
      'https://hei.api.uni-foundation.eu/api/public/v1';

  // European country mapping: Country Name -> Country Code
  // NOTE: These are European countries, but the API now supports ALL countries
  // FEATURE TOGGLE: 'university_country_api_all_countries' controls whether to use all countries or just EU
  static const Map<String, String> _europeanCountryMap = {
    'Austria': 'AT',
    'Belgium': 'BE',
    'Bulgaria': 'BG',
    'Croatia': 'HR',
    'Cyprus': 'CY',
    'Czech Republic': 'CZ',
    'Denmark': 'DK',
    'Estonia': 'EE',
    'Finland': 'FI',
    'France': 'FR',
    'Germany': 'DE',
    'Greece': 'GR',
    'Hungary': 'HU',
    'Ireland': 'IE',
    'Italy': 'IT',
    'Latvia': 'LV',
    'Lithuania': 'LT',
    'Luxembourg': 'LU',
    'Malta': 'MT',
    'Netherlands': 'NL',
    'Poland': 'PL',
    'Portugal': 'PT',
    'Romania': 'RO',
    'Slovakia': 'SK',
    'Slovenia': 'SI',
    'Spain': 'ES',
    'Sweden': 'SE',
  };

  // Fetch European universities using HEI API
  // Integration: Uses HEI /country/{code}/hei endpoint per country
  // Default: AT (Austria) if no country specified (demo data)
  // Filtering: Done client-side after fetching (for efficiency)
  static Future<List<UniversityModel>> fetchEuropeanUniversities({
    String? country,
    String? city,
    String? searchQuery,
  }) async {
    try {
      // Debug: Log API call details
      print(
        '🔍 Fetching universities - Country: $country, City: $city, Query: $searchQuery',
      );

      // If country specified, fetch for that country (HEI API call with country code)
      if (country != null) {
        final countryCode = getCountryCode(country);
        if (countryCode != null) {
          final response = await http.get(
            Uri.parse('$heisApiUrl/country/$countryCode/hei'),
            headers: {'Accept': 'application/vnd.api+json'},
          );
          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            final jsonData = jsonResponse['data'];
            return parseHeisToUniversities(jsonData).where((uni) {
              final cityMatch = city == null || uni.city.contains(city);
              final searchMatch =
                  searchQuery == null ||
                  uni.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  uni.city.toLowerCase().contains(searchQuery.toLowerCase());
              return cityMatch && searchMatch;
            }).toList();
          }
        }
      }

      // Default: fetch Austrian institutions as demo
      final response = await http.get(
        Uri.parse('$heisApiUrl/country/AT/hei'),
        headers: {'Accept': 'application/vnd.api+json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final jsonData = jsonResponse['data'];

        final universities = jsonData.map((json) {
          final attrs = json['attributes'];
          final name =
              attrs['name']?.first?['string'] ?? attrs['label'] ?? 'Unknown';
          final cityName = attrs['city'] ?? '';

          return UniversityModel(
            id: json['id'],
            name: name,
            country: attrs['country'] ?? 'AT',
            city: cityName,
            address: '${cityName}, ${attrs['country'] ?? 'AT'}',
            numberOfStudents: null, // NO FAKE DATA - API doesn't provide this
            rating: null, // NO FAKE DATA - API doesn't provide this
            programs: null, // NO FAKE DATA - API doesn't provide this
            description: 'Higher Education Institution',
            tuitionFeeMin: null, // NO FAKE DATA - API doesn't provide this
            tuitionFeeMax: null, // NO FAKE DATA - API doesn't provide this
            applicationFee: null, // NO FAKE DATA - API doesn't provide this
            website: attrs['website_url'] ?? '',
            email: null, // NO FAKE DATA - API doesn't provide this
            phone: null, // NO FAKE DATA - API doesn't provide this
          );
        }).toList();

        // Apply filters
        return universities.where((uni) {
          final countryMatch = country == null || uni.country == country;
          final cityMatch = city == null || uni.city.contains(city);
          final searchMatch =
              searchQuery == null ||
              uni.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              uni.city.toLowerCase().contains(searchQuery.toLowerCase());
          return countryMatch && cityMatch && searchMatch;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Search universities (European only)
  static Future<List<UniversityModel>> searchUniversities(String query) async {
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse('$baseUrl/universities/search').replace(
        queryParameters: {
          'q': query,
          'region': 'Europe', // Ensure European focus
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => UniversityModel.fromJson(json)).toList();
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // Get universities by country - WORKS FOR ALL COUNTRIES
  // FEATURE TOGGLE: Bypass European check when 'university_country_api_all_countries' is enabled
  static Future<List<UniversityModel>> getUniversitiesByCountry(
    String countryName,
  ) async {
    // FEATURE TOGGLE: When all countries are enabled, skip European check
    if (!isFeatureEnabled('university_country_api_all_countries')) {
      if (!KConstants.euCountries.contains(countryName)) {
        throw Exception('Country not in Europe: $countryName');
      }
    }

    return fetchEuropeanUniversities(country: countryName);
  }

  // Get universities by country code - WORKS FOR ALL COUNTRIES (api3 equivalent)
  // api3: https://hei.api.uni-foundation.eu/api/public/v1/country/BE/hei
  static Future<List<UniversityModel>> getUniversitiesByCountryCode(
    String countryCode,
  ) async {
    // API call using country code directly (bypasses country name mapping)
    try {
      final response = await http.get(
        Uri.parse('$heisApiUrl/country/$countryCode/hei'),
        headers: {'Accept': 'application/vnd.api+json'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final jsonData = jsonResponse['data'];
        return parseHeisToUniversities(jsonData);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get ALL global institutions - API2 equivalent
  // api2: https://hei.api.uni-foundation.eu/api/public/v1/hei
  // Lists all Institutions present in the API globally
  static Future<List<UniversityModel>> getAllGlobalInstitutions() async {
    try {
      final response = await http.get(
        Uri.parse('$heisApiUrl/hei'), // Note: no /country/ prefix for global
        headers: {'Accept': 'application/vnd.api+json'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final jsonData = jsonResponse['data'];
        return parseHeisToUniversities(jsonData);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get single institution by SCHAC identifier - API4 equivalent
  // api4: https://hei.api.uni-foundation.eu/api/public/v1/schac/ugent.be/hei
  // Returns all available data for a single Institution
  static Future<UniversityModel?> getInstitutionBySchac(String schacId) async {
    try {
      final response = await http.get(
        Uri.parse('$heisApiUrl/schac/$schacId/hei'),
        headers: {'Accept': 'application/vnd.api+json'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final jsonData = jsonResponse['data'];
        if (jsonData.isNotEmpty) {
          final universities = parseHeisToUniversities(jsonData);
          return universities.isNotEmpty ? universities.first : null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch countries from HEI API - ALL 43+ countries or European-only
  static Future<List<CountryModel>> getEuropeanCountries() async {
    try {
      developer.log('🚀 Starting API call to: $countriesApiUrl');

      final response = await http.get(
        Uri.parse(countriesApiUrl),
        headers: {'Accept': 'application/vnd.api+json'},
      );

      developer.log('📡 Response status: ${response.statusCode}');
      developer.log('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonData = jsonResponse['data'];
        developer.log('📊 Parsed ${jsonData.length} countries from API');

        // Convert API response to CountryModel objects
        final allCountries = jsonData.map((json) {
          return CountryModel.fromJson({
            'country': json['id'],
            'countryName': json['attributes']['label'],
          });
        }).toList();

        developer.log(
          '🏗️ Created ${allCountries.length} CountryModel objects',
        );

        // FEATURE TOGGLE: Return ALL countries or filter to European-only
        if (isFeatureEnabled('university_country_api_all_countries')) {
          developer.log(
            '🌍 FEATURE: All countries enabled - returning ${allCountries.length} countries',
          );
          return allCountries;
        } else {
          // Filter to European countries only using the mapping
          final europeanCountryCodes = _europeanCountryMap.values;
          final europeanCountries = allCountries
              .where(
                (country) => europeanCountryCodes.contains(country.countryCode),
              )
              .toList();

          developer.log(
            '🇪🇺 FEATURE: European-only enabled - filtered to ${europeanCountries.length} European countries',
          );
          return europeanCountries;
        }
      } else {
        developer.log(
          '❌ API Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('💥 Exception in getEuropeanCountries: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get country code from country name (for API calls)
  static String? getCountryCode(String countryName) {
    return _europeanCountryMap[countryName];
  }

  // Get country name from country code (for display)
  static String? getCountryNameFromCode(String countryCode) {
    return _europeanCountryMap.entries
        .firstWhere(
          (entry) => entry.value == countryCode,
          orElse: () => const MapEntry('', ''),
        )
        .key;
  }

  // Fetch cities by country from HEI API (ALL countries or European-only based on toggle)
  static Future<List<String>> getEuropeanCities(String countryCode) async {
    print('🏙️ Fetching cities for country code: $countryCode');

    // FEATURE TOGGLE: Only check European mapping if toggle is disabled
    if (!isFeatureEnabled('university_city_filter_all_countries') &&
        !_europeanCountryMap.values.contains(countryCode)) {
      print('❌ Invalid country code: $countryCode (European-only mode)');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$heisApiUrl/country/$countryCode/hei'),
        headers: {'Accept': 'application/vnd.api+json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonData = jsonResponse['data'];
        print('📍 Loaded ${jsonData.length} HEIs for cities extraction');

        final Set<String> cities = {};
        for (var item in jsonData) {
          final city = item['attributes']['city'] as String?;
          if (city != null && city.isNotEmpty) {
            cities.add(city);
          }
        }
        print(
          '🏙️ Extracted ${cities.length} unique cities: ${cities.join(', ')}',
        );
        return cities.toList()..sort();
      } else {
        print('❌ API error for cities: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Exception loading cities: $e');
      return [];
    }
  }

  // Helper function to parse HEI JSON to UniversityModel list
  static List<UniversityModel> parseHeisToUniversities(List<dynamic> jsonData) {
    return jsonData.map((json) {
      final attrs = json['attributes'];
      final name =
          attrs['name']?.first?['string'] ?? attrs['label'] ?? 'Unknown';
      final cityName = attrs['city'] ?? '';
      final countryCode = attrs['country'] ?? 'AT';

      final otherIds = attrs['other_id'] as List<dynamic>? ?? [];

      // Extract all identifiers from other_id array
      String? erasmusCode;
      String? picCode;
      String? erasmusCharterCode;
      for (var id in otherIds) {
        final idType = id['type'] as String?;
        final idValue = id['value'] as String?;
        switch (idType) {
          case 'erasmus':
            erasmusCode = idValue;
            break;
          case 'pic':
            picCode = idValue;
            break;
          case 'erasmus-charter':
            erasmusCharterCode = idValue;
            break;
        }
      }

      // Extract mailing address details
      final mailingAddress = attrs['mailing_address'] as Map<String, dynamic>?;
      final recipientName = mailingAddress?['recipient_name'] as String?;
      final addressLine1 = mailingAddress?['address_line_1'] as String?;
      final addressLine2 = mailingAddress?['address_line_2'] as String?;
      final region = mailingAddress?['region'] as String?;

      // Build description from available HEI data
      final isEcheHolder = attrs['eche_holder'] as bool? ?? false;
      final description = _buildHeiDescription(attrs, erasmusCode);

      // NO FAKE DATA - Only use real data from API, set to null if not available
      return UniversityModel(
        id: json['id'],
        name: name,
        country: countryCode,
        city: cityName,
        address: _buildAddressFromMailingAddress(attrs['mailing_address']),
        numberOfStudents: null, // API doesn't provide - show blank space in UI
        rating: null, // API doesn't provide - show blank space in UI
        programs: null, // API doesn't provide - show blank space in UI
        description: description,
        tuitionFeeMin: null, // API doesn't provide - show blank space in UI
        tuitionFeeMax: null, // API doesn't provide - show blank space in UI
        applicationFee: null, // API doesn't provide - show blank space in UI
        website: attrs['website_url'] ?? '',
        email: null, // API doesn't provide - show blank space in UI
        phone: null, // API doesn't provide - show blank space in UI
        // HEI real data fields
        websiteUrl: attrs['website_url'] as String?,
        erasmusCode: erasmusCode,
        isEcheHolder: isEcheHolder,
        postalCode: attrs['mailing_address']?['postal_code'] as String?,
        locality: attrs['mailing_address']?['locality'] as String?,
        createdDate: attrs['created']?['value'] as String?,
        officialName:
            attrs['name']?.first?['string'] as String? ??
            attrs['label'] as String?,

        // NEW: Additional HEI fields from full API response
        abbreviation: attrs['abbreviation'] as String?,
        status: attrs['status'] as bool?,
        changedDate: attrs['changed']?['value'] as String?,
        echeStartDate: attrs['eche_start_date'] as String?,
        echeEndDate: attrs['eche_end_date'] as String?,
        picCode: picCode,
        erasmusCharterCode: erasmusCharterCode,
        recipientName: recipientName,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        region: region,
      );
    }).toList();
  }

  // Helper: Build address from mailing address object
  static String _buildAddressFromMailingAddress(dynamic mailingAddress) {
    if (mailingAddress == null) return '';

    final addressLine1 = mailingAddress['address_line_1'] ?? '';
    final locality = mailingAddress['locality'] ?? '';
    final postalCode = mailingAddress['postal_code'] ?? '';
    final country = mailingAddress['country'] ?? '';

    final parts = [addressLine1, locality, postalCode, country];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  // Helper: Build description from HEI attributes
  static String _buildHeiDescription(dynamic attrs, String? erasmusCode) {
    final name = attrs['label'] ?? 'Higher Education Institution';
    final city = attrs['city'] ?? '';
    final country = attrs['country'] ?? '';
    final isEcheHolder = attrs['eche_holder'] as bool? ?? false;

    String description =
        '$name is a ${isEcheHolder ? 'Erasmus Charter holder' : 'recognized'} higher education institution';

    if (city.isNotEmpty && country.isNotEmpty) {
      description += ' located in $city, $country';
    }

    if (erasmusCode != null && erasmusCode.isNotEmpty) {
      description += ' (Erasmus Code: $erasmusCode)';
    }

    return '$description.';
  }
}
