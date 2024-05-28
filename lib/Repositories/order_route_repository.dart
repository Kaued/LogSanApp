import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/order_route.dart';

class OrderRouteRepository {
  OrderRouteRepository._();

  static final OrderRouteRepository instance = OrderRouteRepository._();
  final _orderRouteCollection = FirebaseFirestore.instance
      .collection("orderRoutes")
      .withConverter<OrderRoute>(
        fromFirestore: (snapshot, options) =>
            OrderRoute.fromJson(snapshot.data()!),
        toFirestore: (orderRoute, options) => orderRoute.toJson(),
      );

  Future<List<QueryDocumentSnapshot<OrderRoute>>> getOrders(
      {List<String>? serviceOrders}) async {
    if (serviceOrders == null || serviceOrders.isEmpty) {
      final orders = await _orderRouteCollection.get();

      return orders.docs;
    }

    final orders = await _orderRouteCollection
        .where("service_order_id", whereIn: serviceOrders)
        .orderBy("date", descending: true)
        .get();

    return orders.docs;
  }

  Future<void> createOrderRoute(OrderRoute orderRoute) async {
    await _orderRouteCollection.add(orderRoute);
  }
}
