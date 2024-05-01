import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';

class ListServiceOrder extends StatefulWidget {
  const ListServiceOrder({super.key});

  @override
  State<ListServiceOrder> createState() => _ListServiceOrderState();
}

class _ListServiceOrderState extends State<ListServiceOrder> {
  bool inSearch = false;
  final controller = ServiceOrderController();
  final dateBr = DateFormat("dd/MM/yyyy hh:mm");

  List<QueryDocumentSnapshot<ServiceOrder>> serviceOrders = [];
  List<QueryDocumentSnapshot<TypeOrder>> typeOrders = [];

  @override
  void initState() {
    super.initState();
    list();
  }

  void list() async {
    var value = await controller.getServiceOrders();
    var type = await controller.getTypeOrders();

    setState(() {
      serviceOrders = value;
      typeOrders = type;
    });
  }

  void toggleAppBar() {
    setState(() {
      inSearch = !inSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Animate(
            effects: const [FadeEffect()],
            child: inSearch
                ? const TextField(
                    decoration: InputDecoration(
                      hintText: "Pesquisar",
                      fillColor: Colors.white,
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                : const Text("Ordem de Serviço"),
          ),
          actions: [
            IconButton(
              onPressed: toggleAppBar,
              icon: Icon(inSearch ? Icons.close : Icons.search),
            )
          ],
        ),
        body: ListView.builder(
          itemCount: serviceOrders.length,
          itemBuilder: (context, index) {
            final serviceOrder = serviceOrders[index].data();
            final typeOrder = typeOrders
                .where(
                    (doc) => doc.id == serviceOrders[index].data().typeOrderId)
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

            return Card(
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
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    subtitle: Container(
                      child: Text(serviceOrder.placeName),
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
