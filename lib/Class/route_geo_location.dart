import 'package:latlong2/latlong.dart';

class RouteGeoLocation {
  RouteGeoLocation({
    required this.code,
    required this.coordinates,
    required this.time,
    required this.distance,
    required this.waypoints,
  });

  RouteGeoLocation.fromJson(Map<String, Object?> json)
      : this(
          code: json["code"]! as String,
          coordinates: (((json["trips"] as List).first["geometry"]
                  as Map<String, Object?>)["coordinates"]! as List)
              .map((e) => LatLng(e[1]! as double, e[0]! as double))
              .toList(),
          time: (json["trips"] as List).first["duration"]! as double,
          distance: (json["trips"] as List).first["distance"]! as double,
          waypoints: (json["waypoints"]! as List)
              .map((e) => LatLng(
                  e["location"][1]! as double, e["location"][0]! as double))
              .toList(),
        );

  String code;
  List<LatLng> coordinates;
  double time;
  double distance;
  List<LatLng> waypoints;
}
