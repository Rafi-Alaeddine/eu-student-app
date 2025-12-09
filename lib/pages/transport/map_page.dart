import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import '../../services/transport_client.dart';

enum TransportMode { metro, bus, tram, sbahn, bikeSharing, taxiRideshare }

class MapPage extends StatefulWidget {
  final TransportMode mode;
  final String city;
  const MapPage({super.key, required this.mode, required this.city});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  bool _isNight = false;

  // Backend client that will call your secure backend (which holds API keys)
  late final TransportClient _transportClient;

  Timer? _pollingTimer;
  final Duration _pollInterval = const Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    // Initialize TransportClient with BACKEND_BASE_URL from .env
    _transportClient = TransportClient(baseUrl: dotenv.env['BACKEND_BASE_URL']);
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    _pollingTimer?.cancel();
    _transportClient.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final permission = await gl.Geolocator.requestPermission();
    if (permission == gl.LocationPermission.denied ||
        permission == gl.LocationPermission.deniedForever) {
      debugPrint('Location permission denied');
      return;
    }
    debugPrint('Location permission granted');
  }

  Future<Uint8List> _loadHQMarkerImage() async {
    var byteData = await rootBundle.load("assets/icons/hq_marker.png");
    return byteData.buffer.asUint8List();
  }

  Future<void> _setupPositionTracking() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    gl.LocationSettings locationSettings = const gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userPositionStream?.cancel();
    userPositionStream =
        gl.Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((gl.Position? position) {
          // You can update user marker/camera here if you want.
        });
  }

  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    // Center over Europe; you can adapt per city
    mapboxMapController?.setCamera(
      mp.CameraOptions(
        zoom: 5,
        center: mp.Point(coordinates: mp.Position(2.3522, 48.8566)),
      ),
    );

    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    _setupPositionTracking();
    _addStandardPOIInteraction();

    // HQ marker (unchanged)
    final pointAnnotationManager = await mapboxMapController?.annotations
        .createPointAnnotationManager();
    final Uint8List imageData = await _loadHQMarkerImage();
    mp.PointAnnotationOptions pointannotationOptions =
        mp.PointAnnotationOptions(
          image: imageData,
          iconSize: 0.3,
          geometry: mp.Point(coordinates: mp.Position(-0.1276, 51.5074)),
        );
    pointAnnotationManager?.create(pointannotationOptions);

    // NEW: start polling backend for stops/vehicles for the selected city/mode
    await _fetchAndRender(); // initial load
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _fetchAndRender());

    // NEW (optional): add French coverage polygons from transport.data.gouv.fr
    await _addFrenchCoveragePolygons();
  }

  /// Fetch stops and vehicles from your backend and render on the map.
  Future<void> _fetchAndRender() async {
    if (mapboxMapController == null) return;

    final city = widget.city;
    final mode = _modeToString(widget.mode);

    try {
      // Parallel fetch
      final results = await Future.wait([
        _transportClient.fetchStops(city: city, mode: mode),
        _transportClient.fetchVehicles(city: city, mode: mode),
      ]);

      final stops = results[0] as List<Stop>;
      final vehicles = results[1] as List<Vehicle>;

      await _renderStopsGeoJson(stops);
      await _renderVehiclesGeoJson(vehicles);
    } catch (e, st) {
      debugPrint('Error fetching or rendering transport data: $e\n$st');
      // no-op; we'll retry on the next poll
    }
  }

  String _modeToString(TransportMode mode) {
    switch (mode) {
      case TransportMode.metro:
        return 'metro';
      case TransportMode.bus:
        return 'bus';
      case TransportMode.tram:
        return 'tram';
      case TransportMode.sbahn:
        return 'sbahn';
      case TransportMode.bikeSharing:
        return 'bikeshare';
      case TransportMode.taxiRideshare:
        return 'taxi';
    }
  }

  Future<void> _renderStopsGeoJson(List<Stop> stops) async {
    if (mapboxMapController == null) return;

    const sourceId = 'stops_source';
    const layerId = 'stops_circle_layer';

    // Remove existing layer/source if present (safe-guard)
    try {
      await mapboxMapController!.style.removeStyleLayer(layerId);
    } catch (_) {}
    try {
      await mapboxMapController!.style.removeStyleSource(sourceId);
    } catch (_) {}

    // Build GeoJSON
    final features = stops.map((s) {
      return {
        "type": "Feature",
        "properties": {"id": s.id, "name": s.name},
        "geometry": {
          "type": "Point",
          "coordinates": [s.lon, s.lat],
        },
      };
    }).toList();

    final geojson = jsonEncode({
      "type": "FeatureCollection",
      "features": features,
    });

    final source = mp.GeoJsonSource(id: sourceId, data: geojson);
    await mapboxMapController!.style.addSource(source);

    final circleLayer = mp.CircleLayer(
      id: layerId,
      sourceId: sourceId,
      circleColor: Colors.blue.toARGB32(),
      circleRadius: 6,
      circleOpacity: 0.9,
    );
    await mapboxMapController!.style.addLayer(circleLayer);
  }

  Future<void> _renderVehiclesGeoJson(List<Vehicle> vehicles) async {
    if (mapboxMapController == null) return;

    const sourceId = 'vehicles_source';
    const layerId = 'vehicles_circle_layer';

    // Remove existing layer/source if present (safe-guard)
    try {
      await mapboxMapController!.style.removeStyleLayer(layerId);
    } catch (_) {}
    try {
      await mapboxMapController!.style.removeStyleSource(sourceId);
    } catch (_) {}

    // Build GeoJSON
    final features = vehicles.map((v) {
      return {
        "type": "Feature",
        "properties": {
          "id": v.id,
          "bearing": v.bearing ?? 0,
          "route": v.route ?? '',
          "delay_seconds": v.delaySeconds ?? 0,
        },
        "geometry": {
          "type": "Point",
          "coordinates": [v.lon, v.lat],
        },
      };
    }).toList();

    final geojson = jsonEncode({
      "type": "FeatureCollection",
      "features": features,
    });

    final source = mp.GeoJsonSource(id: sourceId, data: geojson);
    await mapboxMapController!.style.addSource(source);

    // Use a circle layer to visualize vehicles (simple and performant).
    final circleLayer = mp.CircleLayer(
      id: layerId,
      sourceId: sourceId,
      circleColor: Colors.red.toARGB32(),
      circleRadius: 5,
      circleOpacity: 0.95,
    );
    await mapboxMapController!.style.addLayer(circleLayer);
  }

  Future<void> _addFrenchCoveragePolygons() async {
    if (mapboxMapController == null) return;

    try {
      final resp = await http.get(
        Uri.parse('https://transport.data.gouv.fr/api/stats'),
      );
      if (resp.statusCode != 200) {
        debugPrint('Failed to load coverage GeoJSON: ${resp.statusCode}');
        return;
      }
      final geojsonString = resp.body;

      const sourceId = 'fr_regions';
      const layerId = 'fr_regions_fill';

      // remove old
      try {
        await mapboxMapController!.style.removeStyleLayer(layerId);
      } catch (_) {}
      try {
        await mapboxMapController!.style.removeStyleSource(sourceId);
      } catch (_) {}

      final source = mp.GeoJsonSource(id: sourceId, data: geojsonString);
      await mapboxMapController!.style.addSource(source);

      final fillLayer = mp.FillLayer(
        id: layerId,
        sourceId: sourceId,
        fillColor: Colors.green.toARGB32(),
        fillOpacity: 0.18,
        fillOutlineColor: const Color.fromARGB(255, 225, 148, 5).toARGB32(),
      );
      await mapboxMapController!.style.addLayer(fillLayer);
    } catch (e, st) {
      debugPrint('Error loading French coverage polygons: $e\n$st');
    }
  }

  void _toggleLightPreset() {
    if (mapboxMapController == null) return;
    setState(() {
      _isNight = !_isNight;
    });
    final preset = _isNight ? "night" : "day";
    mapboxMapController!.style.setStyleImportConfigProperty(
      "basemap",
      "lightPreset",
      preset,
    );
  }

  void _addStandardPOIInteraction() {
    if (mapboxMapController == null) return;

    final tapInteraction = mp.TapInteraction(
      mp.StandardPOIs(),
      (poi, _) {
        debugPrint('POI name: ${poi.name}');
        debugPrint('transitMode: ${poi.transitMode}');
        debugPrint('transitStopType: ${poi.transitStopType}');
        debugPrint('transitNetwork: ${poi.transitNetwork}');

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name ?? 'Unknown place',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Mode: ${poi.transitMode ?? "N/A"}'),
                  Text('Stop type: ${poi.transitStopType ?? "N/A"}'),
                  if (poi.transitNetwork != null)
                    Text('Network: ${poi.transitNetwork}'),
                ],
              ),
            );
          },
        );
      },
      radius: 10,
      stopPropagation: false,
    );

    mapboxMapController!.addInteraction(
      tapInteraction,
      interactionID: "tap_interaction_poi",
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.mode) {
      TransportMode.metro => 'Metro',
      TransportMode.bus => 'Bus',
      TransportMode.tram => 'Tram',
      TransportMode.sbahn => 'S-Bahn',
      TransportMode.bikeSharing => 'Bike sharing',
      TransportMode.taxiRideshare => 'Taxi & Rideshare',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapbox Map – $title (${widget.city})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: _isNight ? 'Switch to day' : 'Switch to night',
            icon: Icon(_isNight ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleLightPreset,
          ),
        ],
      ),
      body: mp.MapWidget(
        onMapCreated: _onMapCreated,
        styleUri: mp.MapboxStyles.STANDARD,
        cameraOptions: mp.CameraOptions(zoom: 5, pitch: 55, bearing: 0),
      ),
    );
  }
}
