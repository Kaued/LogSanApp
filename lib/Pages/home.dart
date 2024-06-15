import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthController authController = AuthController.instance;
  final workRouteController = WorkRouteController.instance;
  int workRoutesFinished = 0;
  int totalWorkRoutes = 0;

  int serviceOrdersCanceled = 0;
  int serviceOrdersExpired = 0;
  int serviceOrdersFinished = 0;
  int totalServiceOrders = 0;

  @override
  void initState() {
    super.initState();
    list();
  }

  Future<void> list() async {
    var todayDate = DateTime.now();
    var workRoutesStream = workRouteController.getWorkRoutes(
      field: 'to_date',
      value: todayDate.toIso8601String(),
    );

    workRoutesStream.listen((snapshot) async {
      var totalServiceOrdersCount = 0;
      var serviceOrderFinishedCount = 0;
      var serviceOrdersExpiredCount = 0;
      var serviceOrdersCanceledCount = 0;
      for (var doc in snapshot.docs) {
        var ordersInRoute = await workRouteController.getOrdersInRoute(doc.id);

        totalServiceOrdersCount += ordersInRoute.length;

        for (var order in ordersInRoute) {
          if (order.statusId == 'nFA55R6v6Jnvc8d76pEt') {
            serviceOrderFinishedCount++;
          }

          if(order.statusId == 'rdsEtcKavblvDzkpBZkL') {
            serviceOrdersCanceledCount++;
          }
        }

        var serviceOrdersResponse =
            await workRouteController.getServiceOrdersById(
                ordersInRoute.map((e) => e.serviceOrderId).toList());

        for (var serviceOrder in serviceOrdersResponse) {
          if (serviceOrder.data().maxDate.toDate().isBefore(todayDate)) {
            serviceOrdersExpiredCount++;
          }
        }
      }

      var finishedRoutes = snapshot.docs.where((doc) => doc['finish'] == true);

      setState(() {
        workRoutesFinished = finishedRoutes.length;
        totalWorkRoutes = snapshot.docs.length;
        totalServiceOrders = totalServiceOrdersCount;
        serviceOrdersFinished = serviceOrderFinishedCount;
        serviceOrdersExpired = serviceOrdersExpiredCount;
        serviceOrdersCanceled = serviceOrdersCanceledCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Animate(
          effects: const [FadeEffect()],
          child: Text(
            "Início",
            style: theme.textTheme.titleMedium!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 0,
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Bem-vindo ${authController.user.name}!",
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Color.fromARGB(85, 0, 0, 0),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rotas de Serviço",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Pendentes: ",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "${totalWorkRoutes - workRoutesFinished}",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Finalizadas: ",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "$workRoutesFinished",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total: ",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "$totalWorkRoutes",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Color.fromARGB(85, 0, 0, 0),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Ordens de Serviço",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),                              
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Vencidas: ",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "$serviceOrdersExpired",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Canceladas: ",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "$serviceOrdersCanceled",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Finalizadas: ",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "$serviceOrdersFinished",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total: ",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "$totalServiceOrders",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
