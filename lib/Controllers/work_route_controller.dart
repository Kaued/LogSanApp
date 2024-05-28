import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Repositories/order_route_repository.dart';
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

  static WorkRouteController instance = WorkRouteController._();

  WorkRouteController._();

  Future<List<QueryDocumentSnapshot<Person>>> getUsers() async {
    return await _userRepository.getUsers();
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
    final workRouteId = await _workRouteRepository.createWorkRoute(workRoute);

    
  }
}
