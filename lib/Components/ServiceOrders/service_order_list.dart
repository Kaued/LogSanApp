import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
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
  final controller = ServiceOrderController.instance;

  void deleteServiceOrder(String id) {
    if (id.isNotEmpty) {
      controller.deletedServiceOrder(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            Colors.white,
          ],
          begin: const FractionalOffset(0, 0),
          end: const FractionalOffset(0, 1),
          stops: const [0, .65],
          tileMode: TileMode.clamp,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: ListView.builder(
            itemCount: serviceOrders.length,
            itemBuilder: (context, index) {
              final serviceOrder = serviceOrders[index].data();
              final typeOrder = typeOrders
                  .where((doc) =>
                      doc.id == serviceOrders[index].data().typeOrderId)
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
                case "Desinstalação":
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
                id: serviceOrders[index].id,
                deletedFunction: deleteServiceOrder,
              );
            },
          ),
        ),
      ),
    );
  }
}
