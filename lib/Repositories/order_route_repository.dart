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
}
