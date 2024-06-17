import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/status.dart';
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
  String type = "";

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

    final typeOrderData = typeOrder
        .firstWhere((element) => element.id == orderData.data()!.typeOrderId)
        .data();

    setState(() {
      serviceOrdersData = orderData;
      type = typeOrderData.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Text("Ordem de serviço: "),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(8),
        child: PopupMenuButton(
          offset: const Offset(0, -120),
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                child: Text("Sem Agendamento"),
              ),
              const PopupMenuItem(
                child: Text("Concluída"),
              ),
              const PopupMenuItem(
                child: Text("Cancelada"),
              ),
              const PopupMenuItem(
                child: Text("Agendada"),
              ),
              const PopupMenuItem(
                child: Text("Encaminhada"),
              ),
            ];
          },
        ),
      ),
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Razão social: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.placeName),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Responsável: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.responsible),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Horário: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.openingHours),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Telefone: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.phoneNumber),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text("Número: "),
                            Text(serviceOrdersData!
                                .data()!
                                .address
                                .number
                                .toString()),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Rua: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.address.street),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Bairro: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!
                                .data()!
                                .address
                                .neighborhood),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Cidade: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.address.city),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Estado: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.address.state),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "CEP: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(serviceOrdersData!.data()!.address.cep),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Text(
                              "Tipo de Serviço: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(type),
                          ],
                        ),
                        Card(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Equipamento a Retirar:"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Card(
                  child: Text("Não há informações da ordem de serviço"),
                ),
        ),
      ),
    );
  }
}
