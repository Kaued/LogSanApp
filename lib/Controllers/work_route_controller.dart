import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logsan_app/Models/order_route.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/status.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Repositories/auth_repository.dart';
import 'package:logsan_app/Repositories/order_route_repository.dart';
import 'package:logsan_app/Repositories/service_order_repository.dart';
import 'package:logsan_app/Repositories/status_repository.dart';
import 'package:logsan_app/Repositories/type_order_repository.dart';
import 'package:logsan_app/Repositories/user_repository.dart';
import 'package:logsan_app/Repositories/work_route_repository.dart';

class WorkRouteController {
  final AuthRepository _authRepository = AuthRepository.instance;
  final WorkRouteRepository _workRouteRepository = WorkRouteRepository.instance;
  final OrderRouteRepository _orderRouteRepository =
      OrderRouteRepository.instance;
  final StatusRepository _statusRepository = StatusRepository.instance;
  final UserRepository _userRepository = UserRepository.instance;
  final ServiceOrderRepository _serviceOrderRepository =
      ServiceOrderRepository.instance;
  final TypeOrderRepository _typeOrderRepository = TypeOrderRepository.instance;

  static WorkRouteController instance = WorkRouteController._();

  WorkRouteController._();

  final Map<String, String> columns = {
    "Usuário": "uid",
    "Data": "to_date",
    "Status": "finish",
  };
  final Map<String, String> columnsUser = {
    "Data": "to_date",
    "Status": "finish",
  };

  Future<List<QueryDocumentSnapshot<Person>>> getUsers() async {
    return await _userRepository.getUsers();
  }

  Future<Map<String, String>> getPerson() async {
    User user = _authRepository.getAuthenticatedUser();
    QuerySnapshot<Person> dataUser = await _userRepository.getUserId(user.uid);

    return {
      'id': dataUser.docs[0].id.toString(),
      'isAdmin': dataUser.docs[0].data().isAdmin.toString()
    };
  }

  Stream<QuerySnapshot<WorkRoute>> getWorkRoutes(
      {String? field, String value = "", bool admin = true, String uid = ""}) {
    if (value.isNotEmpty && field != null) {
      if (field == "finish") {
        final orders = _workRouteRepository.getWorkRoutesbyStatus(
          value: value,
          admin: admin,
          uid: uid,
        );
        return orders;
      } else if (field == "to_date") {
        Timestamp date = Timestamp.fromDate(DateTime.parse(value));
        final orders = _workRouteRepository.getWorkRoutesbyDate(
          value: date,
          admin: admin,
          uid: uid,
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

  Future<Stream<QuerySnapshot<WorkRoute>>> getMyWorkRoutes() async {
    if (!_authRepository.isAuthenticated()) {
      throw Exception("Usuário não autenticado");
    }

    User user = _authRepository.getAuthenticatedUser();

    String dataUser = await _userRepository.getIdByUid(user.uid);

    return _workRouteRepository.getWorkRoutesbyUser(value: dataUser);
  }

  Map<String, String> getColumns() {
    return columns;
  }

  Map<String, String> getColumnsUser() {
    return columnsUser;
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

  Future<DocumentSnapshot<WorkRoute>> getWorkRouteById(String id) async {
    return await _workRouteRepository.getWorkRoute(id);
  }

  Future<List<QueryDocumentSnapshot<OrderRoute>>> getOrdersInRoute(
      String routeId) async {
    final ordersInRoute = await _orderRouteRepository.getByRoute(routeId);

    return ordersInRoute;
  }

  Future<List<QueryDocumentSnapshot<Status>>> getStatus() {
    return _statusRepository.getStatus();
  }

  Future<void> finishRoute(String id) async {
    final route = await _workRouteRepository.getWorkRoute(id);

    final routeData = route.data()!;
    final date = DateTime.now();
    routeData.finish = true;
    routeData.finishAt = Timestamp.fromDate(date);

    final ordersInRoute = await _orderRouteRepository.getByRoute(id);

    for (QueryDocumentSnapshot<OrderRoute> order in ordersInRoute) {
      final orderData = order.data();

      if (orderData.statusId == "uQ62CMUv28civO5sUo5M") {
        orderData.statusId = "2bQyWvK3RptcNaSg60N3";
        await _orderRouteRepository.updateOrderRoute(orderData, order.id);
      }
    }

    await _workRouteRepository.updateWorkRoute(routeData, id);
  }
}
