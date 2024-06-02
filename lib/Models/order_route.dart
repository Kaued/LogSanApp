import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRoute {
  OrderRoute({
    required this.routeId,
    required this.serviceOrderId,
    required this.statusId,
    required this.date,
  });

  OrderRoute.fromJson(Map<String, Object?> json)
      : this(
          routeId: json["route_id"]! as String,
          serviceOrderId: json["service_order_id"]! as String,
          statusId: json["status_id"]! as String,
          date: json["date"]! as Timestamp,
        );

  String routeId;
  String serviceOrderId;
  String statusId;
  Timestamp date;

  Map<String, Object?> toJson() {
    return {
      "route_id": routeId,
      "service_order_id": serviceOrderId,
      "status_id": statusId,
      "date": date,
    };
  }
}
