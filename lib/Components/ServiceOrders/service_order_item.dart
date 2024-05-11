import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class ServiceOrderItem extends StatelessWidget {
  const ServiceOrderItem({
    super.key,
    required this.serviceOrder,
    required this.iconType,
    required this.typeOrder,
    required this.id,
    required this.deletedFunction,
  });

  final ServiceOrder serviceOrder;
  final IconData iconType;
  final Function(String id) deletedFunction;
  final String id;
  final TypeOrder typeOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateBr = DateFormat("dd/MM/yyyy hh:mm");

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.serviceOrderForm,
        arguments: FormArguments<ServiceOrder>(
            isAddMode: false, values: serviceOrder, id: id),
      ),
      child: Card(
        color: Colors.grey[200],
        elevation: 2,
        child: Dismissible(
          key: Key(serviceOrder.referenceNumber),
          direction: DismissDirection.endToStart,
          background: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) => deletedFunction(id),
          confirmDismiss: (direction) async {
            return await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Confimar Exclusão da Ordem de Serviço"),
                    content: Text(
                        "A ordem de serviço ${serviceOrder.referenceNumber} será apagada. Deseja continuar?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Confirmar"),
                      )
                    ],
                  );
                });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    iconType,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  Text(
                    typeOrder.name,
                    style: theme.textTheme.labelSmall,
                  )
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    serviceOrder.referenceNumber,
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    " ${dateBr.format(serviceOrder.maxDate.toDate())}",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
              subtitle: Text(serviceOrder.placeName),
            ),
          ),
        ),
      ),
    );
  }
}
