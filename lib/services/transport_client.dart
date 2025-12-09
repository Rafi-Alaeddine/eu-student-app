// lib/services/transport_client.dart
// Client-side wrapper that calls your secure backend endpoints.
// The backend will communicate with free providers (transport.rest, TransitLand, etc.).
//
// The mobile app must send the shared secret MOBILE_API_KEY in the x-api-key header.
// Add MOBILE_API_KEY to your Flutter .env file and load dotenv in main.dart.

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Simple POJO for a transit stop returned by your backend.
class Stop {
  final String id;
  final String name;
  final double lat;
  final double lon;

  Stop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

/// Simple POJO for a vehicle / live position.
class Vehicle {
  final String id;
  final double lat;
  final double lon;
  final double? bearing;
  final double? speed;
  final String? route;
  final int? delaySeconds;

  Vehicle({
    required this.id,
    required this.lat,
    required this.lon,
    this.bearing,
    this.speed,
    this.route,
    this.delaySeconds,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'].toString(),
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      bearing: json['bearing'] != null
          ? (json['bearing'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      route: json['route']?.toString(),
      delaySeconds: json['delay_seconds'] != null
          ? (json['delay_seconds'] as int)
          : null,
    );
  }
}

/// TransportClient communicates with your backend service.
class TransportClient {
  final String baseUrl;
  final http.Client _httpClient = http.Client();

  TransportClient({String? baseUrl})
    : baseUrl =
          baseUrl ??
          dotenv.env['BACKEND_BASE_URL'] ??
          'https://your-backend.example.com';

  Map<String, String> _headers() {
    final k = dotenv.env['MOBILE_API_KEY'] ?? '';
    return {
      'Content-Type': 'application/json',
      if (k.isNotEmpty) 'x-api-key': k,
    };
  }

  /// Fetch stops near the city for the given transport mode.
  Future<List<Stop>> fetchStops({
    required String city,
    required String mode,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/v1/stops',
    ).replace(queryParameters: {'city': city, 'mode': mode});
    final resp = await _httpClient.get(uri, headers: _headers());
    if (resp.statusCode != 200) {
      throw Exception('Failed to load stops: ${resp.statusCode}');
    }
    final jsonBody = json.decode(resp.body);
    final items = (jsonBody['stops'] as List<dynamic>);
    return items.map((e) => Stop.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch live vehicles for the city/mode.
  Future<List<Vehicle>> fetchVehicles({
    required String city,
    required String mode,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/v1/vehicles',
    ).replace(queryParameters: {'city': city, 'mode': mode});
    final resp = await _httpClient.get(uri, headers: _headers());
    if (resp.statusCode != 200) {
      throw Exception('Failed to load vehicles: ${resp.statusCode}');
    }
    final jsonBody = json.decode(resp.body);
    final items = (jsonBody['vehicles'] as List<dynamic>);
    return items
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() {
    _httpClient.close();
  }
}
