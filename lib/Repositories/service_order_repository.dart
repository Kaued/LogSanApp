import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Models/service_order.dart';

class ServiceOrderRepository {
  ServiceOrderRepository._();

  static final ServiceOrderRepository instance = ServiceOrderRepository._();
  final _serviceOrderCollection = FirebaseFirestore.instance
      .collection("serviceOrders")
      .withConverter<ServiceOrder>(
        fromFirestore: (snapshot, options) =>
            ServiceOrder.fromJson(snapshot.data()!),
        toFirestore: (serviceOrder, options) => serviceOrder.toJson(),
      );

  Stream<QuerySnapshot<ServiceOrder>> listServiceOrders(
      {String? field, String value = ""}) {
    if (field != null && field.isNotEmpty) {
      return _serviceOrderCollection
          .where("deleted", isEqualTo: false)
          .orderBy(field)
          .startAt([value]).endAt(["$value\uf8ff"]).snapshots();
    }

    return _serviceOrderCollection
        .where("deleted", isEqualTo: false)
        .snapshots();
  }

  Future<DocumentReference<ServiceOrder>> createServiceOrder(
      ServiceOrder serviceOrder) async {
    return await _serviceOrderCollection.add(serviceOrder);
  }

  Future<void> updateServiceOrder(ServiceOrder serviceOrder, String id) async {
    return await _serviceOrderCollection.doc(id).update(serviceOrder.toJson());
  }

  Future<List<QueryDocumentSnapshot<ServiceOrder>>> getServiceOrders(
      {String value = "", List<String> chooseServiceOrder = const []}) async {
    Query<ServiceOrder> initialRequest = _serviceOrderCollection;

    if (chooseServiceOrder.isNotEmpty) {
      initialRequest = initialRequest.where(FieldPath.documentId,
          whereNotIn: chooseServiceOrder);
    }

    if (value.isEmpty) {
      final serviceOrders = await initialRequest
          .where("deleted", isEqualTo: false)
          .orderBy("referenceNumber")
          .get();

      return serviceOrders.docs;
    }

    final serviceOrders = await initialRequest
        .where("deleted", isEqualTo: false)
        .orderBy("referenceNumber")
        .startAt([value]).endAt(["$value\uf8ff"]).get();

    return serviceOrders.docs;
  }

  Future<List<QueryDocumentSnapshot<ServiceOrder>>> getListServiceOrderById(
      {required List<String> ids}) async {
    final serviceOrders = await _serviceOrderCollection
        .where("deleted", isEqualTo: false)
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return serviceOrders.docs;
  }

  Future<void> deleteServiceOrder(String id) async {
    final serviceOrderResponse = await _serviceOrderCollection.doc(id).get();
    final serviceOrder = serviceOrderResponse.data();

    if (serviceOrder != null) {
      serviceOrder.deleted = true;

      return await _serviceOrderCollection
          .doc(id)
          .update(serviceOrder.toJson());
    }

    throw Exception("Ordem de serviço não encontrada");
  }
}
