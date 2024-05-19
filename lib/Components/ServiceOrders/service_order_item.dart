import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    final dateBr = DateFormat("dd/MM/yyyy HH:mm");

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.serviceOrderForm,
        arguments: FormArguments<ServiceOrder>(
            isAddMode: false, values: serviceOrder, id: id),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: Dismissible(
          key: Key(serviceOrder.referenceNumber),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(20),
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
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    titlePadding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                        color: theme.colorScheme.secondary,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                "Tem certeza?",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    content: Text(
                      "A ordem de serviço ${serviceOrder.referenceNumber} será apagada e não poderá ser mais utilizada. Deseja continuar?",
                      softWrap: true,
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: const Text("Confirmar"),
                      ),
                    ],
                  );
                });
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              leading: SizedBox(
                width: 90,
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
                      style: theme.textTheme.labelSmall,
                    )
                  ],
                ),
              ),
              title: Text(
                serviceOrder.referenceNumber,
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                " ${dateBr.format(serviceOrder.maxDate.toDate())}",
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color:
                      serviceOrder.maxDate.toDate().compareTo(DateTime.now()) <
                              0
                          ? Colors.red
                          : Colors.grey[600],
                ),
              ),
              subtitle: Text(serviceOrder.placeName),
            ),
          ),
        ),
      ),
    );
  }
}
