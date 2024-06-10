import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logsan_app/Class/route_geo_location.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Utils/alerts.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  LatLng? initialLocation;
  final WorkRouteController controller = WorkRouteController.instance;
  final String id = "YySHTEGM5fqisvHnImwV";

  StreamSubscription? subscription;

  RouteGeoLocation? route;
  List<Marker> markers = [];
  List<LatLng> points = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  Future<void> load() async {
    await getLocation();
    await getRoute();
  }

  Future<void> getLocation() async {
    try {
      final location = await controller.getLocation();
      final streamPosition = await controller.getLocationStream();

      if (mounted) {
        setState(() {
          initialLocation = LatLng(location.latitude, location.longitude);
        });

        streamPosition.listen((event) {
          if (mounted) {
            setState(() {
              initialLocation = LatLng(event.latitude, event.longitude);
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alerts.errorMessage(
            context: context,
            message: e.toString(),
            title: "Erro ao obter localização",
          ),
        );
      }
    }
  }

  Future<void> getRoute() async {
    if (initialLocation == null) {
      return;
    }

    final routeRequest = await controller.calculateRoute(
        id: id,
        start: GeoPoint(initialLocation!.latitude, initialLocation!.longitude));

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

    if (mounted) {
      setState(() {
        points = routeRequest.coordinates;
        markers = makersRoute;
        route = routeRequest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialZoom: 15,
          initialCenter: initialLocation ?? const LatLng(-20.8202, -49.3797),
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapDragZoom |
                  InteractiveFlag.scrollWheelZoom |
                  InteractiveFlag.pinchMove |
                  InteractiveFlag.scrollWheelZoom),
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
            if (initialLocation != null)
              Marker(
                width: 80.0,
                height: 80.0,
                point: initialLocation!,
                child: const Icon(
                  Icons.circle,
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
