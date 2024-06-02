import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';

class ServiceOrderListRoute extends StatelessWidget {
  final List<QueryDocumentSnapshot<ServiceOrder>> serviceOrders;
  final List<QueryDocumentSnapshot<TypeOrder>> typeOrders;
  final void Function(String) deleteServiceOrder;
  final List<String> chooseServiceOrders;

  const ServiceOrderListRoute({
    super.key,
    required this.serviceOrders,
    required this.typeOrders,
    required this.deleteServiceOrder,
    required this.chooseServiceOrders,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return serviceOrders.isNotEmpty
        ? ListView.builder(
            itemCount: serviceOrders.length,
            itemBuilder: (context, index) {
              if (serviceOrders.isEmpty) {
                return const Text("Nenhuma ordem de serviço cadastrada.");
              }

              final id = serviceOrders[index].id;
              final serviceOrder = serviceOrders[index].data();

              final typeOrder = typeOrders
                  .firstWhere(
                    (element) => element.id == serviceOrder.typeOrderId,
                  )
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

              return Card(
                elevation: 2,
                child: Dismissible(
                  onDismissed: (direction) {
                    deleteServiceOrder(id);
                  },
                  key: Key(id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: SizedBox(
                        width: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              iconType,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                            Text(
                              typeOrder.name,
                              style: theme.textTheme.labelSmall!.copyWith(
                                fontSize: 8,
                              ),
                            )
                          ],
                        ),
                      ),
                      title: Text(serviceOrder.referenceNumber),
                      subtitle: Text(
                          "${serviceOrder.address.city} - ${serviceOrder.address.neighborhood}"),
                    ),
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text(
              "Não há ordens de serviço selecionadas",
              style: theme.textTheme.titleMedium!.copyWith(
                color: Colors.grey[600],
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          );
  }
}
