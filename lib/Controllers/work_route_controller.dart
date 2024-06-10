import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logsan_app/Class/route_geo_location.dart';
import 'package:logsan_app/Models/order_route.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Repositories/order_route_repository.dart';
import 'package:logsan_app/Repositories/route_calculate_repository.dart';
import 'package:logsan_app/Repositories/service_order_repository.dart';
import 'package:logsan_app/Repositories/status_repository.dart';
import 'package:logsan_app/Repositories/type_order_repository.dart';
import 'package:logsan_app/Repositories/user_repository.dart';
import 'package:logsan_app/Repositories/work_route_repository.dart';

class WorkRouteController {
  final WorkRouteRepository _workRouteRepository = WorkRouteRepository.instance;
  final OrderRouteRepository _orderRouteRepository =
      OrderRouteRepository.instance;
  final StatusRepository _statusRepository = StatusRepository.instance;
  final UserRepository _userRepository = UserRepository.instance;
  final ServiceOrderRepository _serviceOrderRepository =
      ServiceOrderRepository.instance;
  final TypeOrderRepository _typeOrderRepository = TypeOrderRepository.instance;
  final RouteCalculateRepository _routeCalculateRepository =
      RouteCalculateRepository.instance;

  static WorkRouteController instance = WorkRouteController._();

  WorkRouteController._();

  final Map<String, String> columns = {
    "Usuário": "uid",
    "Data": "to_date",
    "Status": "finish",
  };

  Future<List<QueryDocumentSnapshot<Person>>> getUsers() async {
    return await _userRepository.getUsers();
  }

  Stream<QuerySnapshot<WorkRoute>> getWorkRoutes(
      {String? field, String value = ""}) {
    print(field);
    if (value.isNotEmpty && field != null) {
      if (field == "finish") {
        final orders = _workRouteRepository.getWorkRoutesbyStatus(
          value: value,
        );
        return orders;
      } else if (field == "to_date") {
        Timestamp date = Timestamp.fromDate(DateTime.parse(value));
        final orders = _workRouteRepository.getWorkRoutesbyDate(
          value: date,
        );
        return orders;
      } else if (field == "uid") {
        final orders = _workRouteRepository.getWorkRoutesbyUser(
          value: value,
        );
        return orders;
      }
    }

    final orders = _workRouteRepository.getWorkRoutes();
    return orders;
  }

  Map<String, String> getColumns() {
    return columns;
  }

  Future<bool> delete(String id) async {
    try {
      await _workRouteRepository.delete(id);
    } catch (e) {
      throw Exception(e);
    }

    return true;
  }

  Future<List<QueryDocumentSnapshot<ServiceOrder>>> getServiceOrderEnables(
      {String search = "", List<String> chooseServiceOrders = const []}) async {
    final serviceOrders = await _serviceOrderRepository.getServiceOrders(
        value: search, chooseServiceOrder: chooseServiceOrders);

    final ordersInRoute = await _orderRouteRepository.getOrders(
        serviceOrders: serviceOrders.map((e) => e.id).toList());

    const List<String> status = [
      "2bQyWvK3RptcNaSg60N3", // Sem Agendamento
      "xQdJryD4qLyzVnz6l7As" // Agendada
    ];

    final serviceOrdersEnable = serviceOrders.where((serviceOrder) {
      if (!ordersInRoute
          .map((e) => e.data().serviceOrderId)
          .toList()
          .contains(serviceOrder.id)) {
        return true;
      }

      final lastRoute = ordersInRoute.firstWhere(
        (element) => element.data().serviceOrderId == serviceOrder.id,
      );

      final statusId = lastRoute.data().statusId;

      return status.contains(statusId);
    }).toList();

    return serviceOrdersEnable;
  }

  Future<List<QueryDocumentSnapshot<TypeOrder>>> getTypeOrders() async {
    return await _typeOrderRepository.listTypeOrder();
  }

  Future<List<QueryDocumentSnapshot<ServiceOrder>>> getServiceOrdersById(
      List<String> serviceOrders) async {
    if (serviceOrders.isEmpty) {
      return [];
    }

    return await _serviceOrderRepository.getListServiceOrderById(
        ids: serviceOrders);
  }

  Future<void> createWorkRoute(
      {required WorkRoute workRoute,
      required List<String> chooseServiceOrder}) async {
    if (chooseServiceOrder.isEmpty) {
      throw Exception("Nenhuma ordem de serviço selecionada");
    }

    final workRouteId = await _workRouteRepository.createWorkRoute(workRoute);

    for (String serviceOrder in chooseServiceOrder) {
      final orderRoute = OrderRoute(
          serviceOrderId: serviceOrder,
          routeId: workRouteId,
          statusId: "uQ62CMUv28civO5sUo5M",
          date: Timestamp.now());

      await _orderRouteRepository.createOrderRoute(orderRoute);
    }

    return;
  }

  Future<List<String>> getChooseServiceOrder(String routeId) async {
    final ordersInRoute = await _orderRouteRepository.getByRoute(routeId);

    return ordersInRoute.map((e) => e.data().serviceOrderId).toList();
  }

  Future<void> updateWorkRoute({
    required WorkRoute workRoute,
    required String id,
    required List<String> chooseServiceOrder,
  }) async {
    if (chooseServiceOrder.isEmpty) {
      throw Exception("Nenhuma ordem de serviço selecionada");
    }

    await _workRouteRepository.updateWorkRoute(workRoute, id);

    final ordersInRoute = await _orderRouteRepository.getByRoute(id);

    final ordersInRouteIdsToDelete = ordersInRoute
        .where((e) => !chooseServiceOrder.contains(e.data().serviceOrderId))
        .toList();

    for (QueryDocumentSnapshot<OrderRoute> orderToDelete
        in ordersInRouteIdsToDelete) {
      await _orderRouteRepository.deleteOrderRoute(orderToDelete.id);
    }

    final ordersInRouteIdsToCreate = chooseServiceOrder
        .where((element) => !ordersInRoute
            .map((e) => e.data().serviceOrderId)
            .toList()
            .contains(element))
        .toList();

    for (String orderToCreate in ordersInRouteIdsToCreate) {
      final orderRoute = OrderRoute(
          serviceOrderId: orderToCreate,
          routeId: id,
          statusId: "uQ62CMUv28civO5sUo5M",
          date: Timestamp.now());

      await _orderRouteRepository.createOrderRoute(orderRoute);
    }

    return;
  }

  Future<RouteGeoLocation> calculateRoute(
      {required String id, required GeoPoint start}) async {
    final workRoute = await _workRouteRepository.findWorkRoute(id);
    final ordersInRoute = await _orderRouteRepository.getByRoute(workRoute.id);

    final serviceOrdersId =
        ordersInRoute.map((e) => e.data().serviceOrderId).toList();

    final serviceOrder = await _serviceOrderRepository.getListServiceOrderById(
        ids: serviceOrdersId);

    final List<GeoPoint> points =
        serviceOrder.map((e) => e.data().geoLocation).toList();

    const GeoPoint end = GeoPoint(-20.800379, -49.3579227);

    try {
      final route = await _routeCalculateRepository.calculateRoute(
        points: points,
        start: start,
        end: end,
      );

      return route;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Localização está desabilitado.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permissão de localização negada para sempre, não podemos solicitar permissão.');
    }
    return true;
  }

  Future<Position> getLocation() async {
    try {
      final bool permission = await _handleLocationPermission();

      if (!permission) {
        throw Exception("Permissão de localização negada");
      }
    } catch (e) {
      throw Exception(e);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return position;
    } catch (e) {
      throw Exception("Erro ao obter localização");
    }
  }

  Future<Stream<Position>> getLocationStream() async {
    try {
      final bool permission = await _handleLocationPermission();

      if (!permission) {
        throw Exception("Permissão de localização negada");
      }
    } catch (e) {
      throw Exception(e);
    }

    try {
      const LocationSettings options = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );
      final position = Geolocator.getPositionStream(locationSettings: options);

      return position;
    } catch (e) {
      throw Exception("Erro ao obter localização");
    }
  }
}
