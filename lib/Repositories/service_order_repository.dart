import 'package:cloud_firestore/cloud_firestore.dart';
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
          .orderBy(field)
          .startAt([value]).snapshots();
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
