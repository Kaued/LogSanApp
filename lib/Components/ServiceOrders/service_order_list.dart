import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';

import 'service_order_item.dart';

class ServiceOrderList extends StatelessWidget {
  ServiceOrderList({
    super.key,
    required this.serviceOrders,
    required this.typeOrders,
  });

  final List<QueryDocumentSnapshot<ServiceOrder>> serviceOrders;
  final List<QueryDocumentSnapshot<TypeOrder>> typeOrders;
  final dateBr = DateFormat("dd/MM/yyyy hh:mm");

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: serviceOrders.length,
      itemBuilder: (context, index) {
        final serviceOrder = serviceOrders[index].data();
        final typeOrder = typeOrders
            .where((doc) => doc.id == serviceOrders[index].data().typeOrderId)
            .first
            .data();

        IconData iconType = Icons.precision_manufacturing;

        switch (typeOrder.name) {
          case "Troca":
            iconType = Icons.change_circle_outlined;
            break;
          case "Instalação":
            iconType = Icons.add_business_outlined;
            break;
          case "Desistalação":
            iconType = Icons.remove;
            break;
          case "Suprimentos":
            iconType = Icons.delivery_dining;
            break;
          default:
        }

        return ServiceOrderItem(
          serviceOrder: serviceOrder,
          iconType: iconType,
          typeOrder: typeOrder,
        );
      },
    );
  }
}