import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Repositories/service_order_repository.dart';
import 'package:logsan_app/Repositories/type_order_repository.dart';

class ServiceOrderController {
  final ServiceOrderRepository _serviceOrderRepository =
      ServiceOrderRepository.instance;

  final TypeOrderRepository _typeOrderRepository = TypeOrderRepository.instance;

  Future<List<QueryDocumentSnapshot<ServiceOrder>>> getServiceOrders() async {
    final orders = await _serviceOrderRepository.listServiceOrders();

    return orders;
  }

  Future<List<QueryDocumentSnapshot<TypeOrder>>> getTypeOrders() async {
    final types = await _typeOrderRepository.listTypeOrder();

    return types;
  }
}
