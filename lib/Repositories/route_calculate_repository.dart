import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:logsan_app/Class/route_geo_location.dart';

class RouteCalculateRepository {
  RouteCalculateRepository._();

  static final RouteCalculateRepository instance = RouteCalculateRepository._();

  final String _url = "http://router.project-osrm.org/";

  Future<RouteGeoLocation> calculateRoute(
      {required List<GeoPoint> points,
      required GeoPoint start,
      required GeoPoint end}) async {
    final geoPointsString =
        points.map((e) => "${e.longitude},${e.latitude}").join(";");

    final url = Uri.parse("$_url"
        "trip/v1/driving/${start.longitude},${start.latitude};$geoPointsString;${end.longitude},${end.latitude}?steps=false&roundtrip=false&source=first&destination=last&geometries=geojson&overview=full");

    final response = await http.get(url);

    if (response.statusCode >= 200 && response.statusCode <= 203) {
      final json = convert.jsonDecode(response.body) as Map<String, Object?>;

      if (json.isEmpty) {
        throw Exception("Rota não encontrada");
      }

      return RouteGeoLocation.fromJson(json);
    }

    throw Exception("Rota não encontrada");
  }
}
