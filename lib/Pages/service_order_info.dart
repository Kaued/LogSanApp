import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Components/Equipments/equipment_item.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/equipment.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';

class ServiceOrderInfo extends StatefulWidget {
  const ServiceOrderInfo({super.key, required this.arguments});

  final String arguments;

  @override
  State<ServiceOrderInfo> createState() => _ServiceOrderInfo();
}

class _ServiceOrderInfo extends State<ServiceOrderInfo> {
  final controllerOrder = ServiceOrderController.instance;
  DocumentSnapshot<ServiceOrder>? serviceOrdersData;
  DocumentSnapshot<Equipment>? installEquipments;
  DocumentSnapshot<Equipment>? removeEquipments;
  String type = "";
  String? status;

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    final String orderDataId = widget.arguments;

    // Dados das ordens de serviço na rota
    final DocumentSnapshot<ServiceOrder> orderData =
        await controllerOrder.getServiceOrderById(orderDataId);
    final List<QueryDocumentSnapshot<TypeOrder>> typeOrder =
        await controllerOrder.getTypeOrders();
    final String? statusResponse =
        await controllerOrder.getLastStatusInOrder(orderDataId);

    if (orderData.data()!.installEquipment != null) {
      final installEquipmentsResponse = await controllerOrder
          .findEquipment(orderData.data()!.installEquipment!);

      setState(() {
        installEquipments = installEquipmentsResponse;
      });
    }

    if (orderData.data()!.removeEquipment != null) {
      final removeEquipmentsResponse = await controllerOrder
          .findEquipment(orderData.data()!.removeEquipment!);

      setState(() {
        removeEquipments = removeEquipmentsResponse;
      });
    }

    final typeOrderData = typeOrder
        .firstWhere((element) => element.id == orderData.data()!.typeOrderId)
        .data();

    setState(() {
      serviceOrdersData = orderData;
      type = typeOrderData.name;
      status = statusResponse;
    });
  }

  Future<void> changeStatus(
      BuildContext context, ThemeData theme, String status) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            titlePadding: const EdgeInsets.all(0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                color: theme.colorScheme.secondary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: const Text(
              "Tem certeza que deseja alterar o status da ordem de serviço?",
              softWrap: true,
              style: TextStyle(
                fontSize: 14,
              ),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: const Text("Confirmar"),
              ),
            ],
          );
        });

    if (confirm!) {
      if (status == "xQdJryD4qLyzVnz6l7As") {
        DateTime? date = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: DateTime.now(),
          currentDate: DateTime.now(),
        );

        if (context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (date != null && time != null) {
            final dateTimeSelect = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);

            await controllerOrder.updateStatusServiceOrder(
                id: widget.arguments, status: status, newDate: dateTimeSelect);
          }
        }

        return;
      }

      await controllerOrder.updateStatusServiceOrder(
          id: widget.arguments, status: status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          children: [
            Text("Ordem de serviço: "),
          ],
        ),
      ),
      floatingActionButton: status == "uQ62CMUv28civO5sUo5M" && status != null
          ? Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(8),
              child: PopupMenuButton<String>(
                offset: const Offset(0, -120),
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: "2bQyWvK3RptcNaSg60N3",
                      child: Text("Sem Agendamento"),
                    ),
                    const PopupMenuItem(
                      value: "nFA55R6v6Jnvc8d76pEt",
                      child: Text("Concluída"),
                    ),
                    const PopupMenuItem(
                      value: "rdsEtcKavblvDzkpBZkL",
                      child: Text("Cancelada"),
                    ),
                    const PopupMenuItem(
                      value: "xQdJryD4qLyzVnz6l7As",
                      child: Text("Agendada"),
                    ),
                  ];
                },
                onSelected: (value) {
                  changeStatus(context, theme, value);
                },
              ),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.clamp,
            stops: const [0, 0.65],
            colors: [
              theme.colorScheme.primary,
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        height: screen.height,
        width: screen.width,
        child: SingleChildScrollView(
          child: serviceOrdersData != null
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Razão social: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.placeName,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Responsável: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.responsible,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Horário: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.openingHours,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Telefone: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.phoneNumber,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Número: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                                serviceOrdersData!
                                    .data()!
                                    .address
                                    .number
                                    .toString(),
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Rua: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.address.street,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Bairro: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                                serviceOrdersData!.data()!.address.neighborhood,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Cidade: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.address.city,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Estado: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.address.state,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "CEP: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(serviceOrdersData!.data()!.address.cep,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Tipo de Serviço: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(type, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        EquipmentItem(
                          installEquipment: installEquipments?.data(),
                          removeEquipment: removeEquipments?.data(),
                        )
                      ],
                    ),
                  ),
                )
              : const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Não há informações da ordem de serviço"),
                  ),
                ),
        ),
      ),
    );
  }
}
