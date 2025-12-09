// class TransitStop {
//   final String id;
//   final String name;
//   final LatLng location;
//   final TransportMode type;
//   final List<String> routeIds;
// }

// class TransitRoute {
//   final String id;
//   final String name;
//   final TransportMode type;
//   final List<TransitStop> stops;
//   final String color; // From GTFS
// }

// class TripPlan {
//   final List<TripSegment> segments;
//   final Duration totalTime;
//   final double walkingDistance;
//   final double cost;
// }

// class TripSegment {
//   final TransportMode mode;
//   final String? routeName;
//   final DateTime departureTime;
//   final DateTime arrivalTime;
//   final TransitStop? fromStop;
//   final TransitStop? toStop;
// }
