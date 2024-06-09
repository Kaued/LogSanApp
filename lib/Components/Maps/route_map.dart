import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logsan_app/Class/route_geo_location.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final LatLng initialLocation = const LatLng(-20.8202, -49.3797);
  final WorkRouteController controller = WorkRouteController.instance;
  final String id = "YySHTEGM5fqisvHnImwV";
  RouteGeoLocation? route;
  List<Marker> markers = [];
  List<LatLng> points = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRoute();
  }

  Future<void> getRoute() async {
    final routeRequest = await controller.calculateRoute(
        id: id,
        start: GeoPoint(initialLocation.latitude, initialLocation.longitude));

    final List<Marker> makersRoute = routeRequest.waypoints.map((e) {
      final marker = Marker(
        width: 80.0,
        height: 80.0,
        point: e,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 45.0,
        ),
      );

      return marker;
    }).toList();

    makersRoute.removeAt(0);

    setState(() {
      points = routeRequest.coordinates;
      markers = makersRoute;
      route = routeRequest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialZoom: 15,
          initialCenter: LatLng(-20.8202, -49.3797),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleatflet.flutter_map.example',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 5.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(markers: [
            const Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(-20.8202, -49.3797),
              child: Icon(
                Icons.location_on,
                color: Colors.green,
                size: 45.0,
              ),
            ),
            ...markers
          ]),
        ],
      ),
    );
  }
}
