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

  Future<List<QueryDocumentSnapshot<ServiceOrder>>> listServiceOrders(
      {String? field, String value = ""}) async {
    return await _serviceOrderCollection.get().then((value) => value.docs);
  }
}
