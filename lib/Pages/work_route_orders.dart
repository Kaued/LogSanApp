import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/order_route.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/status.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class WorkRouteOrders extends StatefulWidget {
  const WorkRouteOrders({super.key, required this.arguments});

  final String arguments;

  @override
  State<WorkRouteOrders> createState() => _WorkRouteOrdersState();
}

class _WorkRouteOrdersState extends State<WorkRouteOrders> {
  final controllerRoute = WorkRouteController.instance;
  List<QueryDocumentSnapshot<ServiceOrder>> serviceOrdersData = [];
  DocumentSnapshot<WorkRoute>? workRoute;
  List<QueryDocumentSnapshot<OrderRoute>> osWorkRoute = [];
  List<QueryDocumentSnapshot<Status>> statusOrders = [];
  List<QueryDocumentSnapshot<TypeOrder>> typeOrderData = [];
  final dateFormat = DateFormat("dd/MM/yyyy");
  String? routeId;

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    final String routeDataId = widget.arguments;

    final DocumentSnapshot<WorkRoute> workRouteData =
        await controllerRoute.getWorkRouteById(routeDataId);

    // Relação status OS
    final List<QueryDocumentSnapshot<OrderRoute>> ordersInWorkRoute =
        await controllerRoute.getOrdersInRoute(routeDataId);

    final List<String> ordersInWorkRouteId =
        ordersInWorkRoute.map((item) => item.data().serviceOrderId).toList();

    // Dados das ordens de serviço na rota
    final List<QueryDocumentSnapshot<ServiceOrder>> ordersData =
        await controllerRoute.getServiceOrdersById(ordersInWorkRouteId);

    // Status das ordens de serviço
    final List<QueryDocumentSnapshot<Status>> statusData =
        await controllerRoute.getStatus();

    final List<QueryDocumentSnapshot<TypeOrder>> typeOrder =
        await controllerRoute.getTypeOrders();

    setState(() {
      workRoute = workRouteData;
      osWorkRoute = ordersInWorkRoute;
      serviceOrdersData = ordersData;
      statusOrders = statusData;
      typeOrderData = typeOrder;
      routeId = routeDataId;
    });
  }

  Future<void> _onSelected(int value, ThemeData theme) async {
    switch (value) {
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.map, arguments: routeId);
        break;
      case 2:
        final confirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.spaceBetween,
                titlePadding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                title: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    color: theme.colorScheme.secondary,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  "Tem certeza que deseja finalizar a rota?",
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
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
                          vertical: 8, horizontal: 12),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text("Confirmar"),
                  ),
                ],
              );
            });

        if (confirm == true) {
          await controllerRoute.finishRoute(routeId!);

          if (mounted) {
            Navigator.of(context).pop();
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Animate(
          effects: const [FadeEffect()],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rota de serviço",
                style:
                    theme.textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              Text(
                workRoute != null
                    ? dateFormat.format(workRoute!.data()!.toDate.toDate())
                    : "Carregando",
                style:
                    theme.textTheme.titleMedium!.copyWith(color: Colors.white),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: workRoute != null && !workRoute!.data()!.finish
          ? Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(8),
              child: PopupMenuButton<int>(
                offset: const Offset(0, -120),
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.map),
                          Text("Mapa"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.file_download_done_outlined),
                          Text("Finalizar rota")
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (value) => _onSelected(value, theme),
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
          child: Column(
            children: [
              Column(
                children: [
                  Card(
                    elevation: 0,
                    child: Container(
                      height: screen.height * 0.8 + 16,
                      padding: const EdgeInsets.only(top: 8),
                      child: ListView.builder(
                        itemCount: serviceOrdersData.length,
                        itemBuilder: (context, index) {
                          if (serviceOrdersData.isEmpty) {
                            return const Text(
                                "Nenhuma ordem de serviço encontrada nesta rota");
                          }

                          // É como se este .data() vai lá no repositório e executa as funções de conversão
                          final typeOrderFinal = typeOrderData
                              .firstWhere((element) =>
                                  element.id ==
                                  serviceOrdersData[index].data().typeOrderId)
                              .data();

                          IconData iconType = Icons.precision_manufacturing;

                          switch (typeOrderFinal.name) {
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
                          }

                          final relationStatus = osWorkRoute.firstWhere(
                              (element) =>
                                  element.data().serviceOrderId ==
                                  serviceOrdersData[index].id);

                          final status = statusOrders.firstWhere((element) =>
                              element.id == relationStatus.data().statusId);

                          Color colorStatus = Colors.black;
                          switch (status.data().name) {
                            //cinza
                            case "Sem Agendamento":
                              colorStatus = Colors.grey[700]!;
                              break;
                            // verde
                            case "Concluída":
                              colorStatus = Colors.green;
                              break;
                            // vermelho
                            case "Cancelada":
                              colorStatus = Colors.red;
                              break;
                            // Amarelo
                            case "Agendada":
                              colorStatus = Colors.yellow;
                              break;
                            case "Encaminhada":
                              colorStatus = theme.colorScheme.primary;
                              break;
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  AppRoutes.serviceOrderInfo,
                                  arguments: serviceOrdersData[index].id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Card(
                                elevation: 0,
                                color: Colors.grey[200],
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 4),
                                    child: ListTile(
                                      leading: SizedBox(
                                        width: 70,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Icon(
                                              iconType,
                                              size: 32,
                                              color: theme.colorScheme.primary,
                                            ),
                                            Text(
                                              typeOrderFinal.name,
                                              style: theme.textTheme.labelSmall!
                                                  .copyWith(
                                                fontSize: 8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              serviceOrdersData[index]
                                                  .data()
                                                  .referenceNumber,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              status.data().name.toLowerCase(),
                                              style: TextStyle(
                                                color: colorStatus,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                          "${serviceOrdersData[index].data().address.city} - ${serviceOrdersData[index].data().address.neighborhood}"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
