import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:logsan_app/Class/route_geo_location.dart';
import 'package:logsan_app/Components/loading_positioned.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Utils/alerts.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with TickerProviderStateMixin {
  final WorkRouteController controller = WorkRouteController.instance;
  final String id = "YySHTEGM5fqisvHnImwV";
  late final AnimatedMapController mapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  StreamSubscription? subscription;

  LatLng? initialLocation;
  RouteGeoLocation? route;
  List<AnimatedMarker> markers = [];
  List<LatLng> pointsOriginal = [];
  List<LatLng> points = [];
  bool loading = false;
  double rotation = 0.0;

  bool focusInLocation = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
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

        if (focusInLocation) {
          mapController.centerOnPoint(initialLocation!);
        }

        subscription = streamPosition.listen((event) async {
          if (mounted) {
            final newLocation = LatLng(event.latitude, event.longitude);
            if (focusInLocation) {
              mapController.centerOnPoint(newLocation);
            }

            setState(() {
              rotation = event.heading;
              initialLocation = newLocation;
            });

            try {
              final newPoints = controller.getPointsByLocationUser(
                  points: points, userLocation: newLocation);

              setState(() {
                points = newPoints;
              });
            } catch (e) {
              final isInPath = controller.isInPath(newLocation, points);

              if (!isInPath) {
                await getRoute();
                subscription?.cancel();
                getLocation();
              }
            }
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

    setState(() {
      loading = true;
    });

    try {
      final routeRequest = await controller.calculateRoute(
          id: id,
          start:
              GeoPoint(initialLocation!.latitude, initialLocation!.longitude));

      final List<AnimatedMarker> makersRoute = routeRequest.waypoints.map((e) {
        final marker = AnimatedMarker(
          width: 80.0,
          height: 80.0,
          point: e,
          builder: (context, animation) => const Icon(
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
          pointsOriginal = routeRequest.coordinates;
          markers = makersRoute;
          route = routeRequest;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alerts.errorMessage(
            context: context,
            message: "Não foi possível obter a rota",
            title: "Erro ao obter rota",
          ),
        );
      }

      subscription?.cancel();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialZoom: 15,
              initialCenter:
                  initialLocation ?? const LatLng(-20.8202, -49.3797),
              interactionOptions: InteractionOptions(
                flags: focusInLocation
                    ? InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapDragZoom |
                        InteractiveFlag.scrollWheelZoom
                    : InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapDragZoom |
                        InteractiveFlag.scrollWheelZoom |
                        InteractiveFlag.pinchMove |
                        InteractiveFlag.scrollWheelZoom,
              ),
            ),
            mapController: mapController.mapController,
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleatflet.flutter_map.example',
              ),
              if (initialLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [initialLocation!, ...points],
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              AnimatedMarkerLayer(markers: [
                if (initialLocation != null)
                  AnimatedMarker(
                    width: 80.0,
                    height: 80.0,
                    point: initialLocation!,
                    rotate: true,
                    key: const Key("useLocation"),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, animation) => Transform(
                      transform: Matrix4.identity()..rotateZ(rotation),
                      child: const Icon(
                        Icons.send,
                        color: Colors.green,
                        size: 45.0,
                      ),
                    ),
                  ),
                ...markers
              ]),
            ],
          ),
          Positioned(
            right: 30,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                onPressed: () {
                  if (initialLocation != null && !focusInLocation) {
                    mapController.centerOnPoint(initialLocation!);
                  }
                  setState(() {
                    focusInLocation = !focusInLocation;
                  });
                },
                icon: Icon(
                    focusInLocation
                        ? Icons.location_disabled
                        : Icons.location_searching_outlined,
                    color: Colors.white),
              ),
            ),
          ),
          LoadingPositioned(loading: loading),
        ],
      ),
    );
  }
}
