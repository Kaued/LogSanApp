import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Components/WorkRoutes/work_routes_search.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class WorkRoutesListUser extends StatefulWidget {
  const WorkRoutesListUser({super.key});

  @override
  State<WorkRoutesListUser> createState() => _WorkRoutesListUserState();
}

class _WorkRoutesListUserState extends State<WorkRoutesListUser> {
  bool inSearch = false;
  final controller = WorkRouteController.instance;
  String field = "";
  // Lista das work routes que atualiza por si
  Stream<QuerySnapshot<WorkRoute>>? streamWorkRoutes = const Stream.empty();
  List<QueryDocumentSnapshot<Person>> user = [];
  Timer? _debounce;
  final dateFormat = DateFormat("dd/MM/yyyy");
  Map<String, String>? dataUser;
  bool showDayRoute = false;
  bool showPreviousRoutes = true;

  @override
  void initState() {
    super.initState();
    list();

    setState(() {
      // Já seleciona um valor pra quando for pesquisar
      field = controller.getColumnsUser().entries.first.value;
    });
  }

  void list() async {
    var workRoutes = await controller.getMyWorkRoutes();
    var usersData = await controller.getUsers();
    final dataUserRequest = await controller.getPerson();

    setState(() {
      streamWorkRoutes = workRoutes;
      user = usersData;
      dataUser = dataUserRequest;
    });
  }

  void toggleSearch() async {
    if (inSearch) {
      var workRoutes = await controller.getMyWorkRoutes();

      setState(() {
        inSearch = !inSearch;
        streamWorkRoutes = workRoutes;
      });

      return;
    }

    setState(() {
      inSearch = !inSearch;
    });
  }

  // Função que cancela a pesquisa por timer
  void _onSearchChanged(String query) {
    // Se o timer pra pesquisar estiver ativo
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(seconds: 1), () {
      var workRoutes = controller.getWorkRoutes(
          field: field, value: query, admin: false, uid: dataUser!["id"]!);
      setState(() {
        streamWorkRoutes = workRoutes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;
    final double expandedWidth = screen.width - 130;
    const double expandedHeight = 70;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: inSearch
            ? WorkRoutesSearch(field: field, onSearch: _onSearchChanged)
            : Text(
                "Rotas de Serviços",
                style:
                    theme.textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
        actions: [
          IconButton(
            onPressed: toggleSearch,
            icon: Icon(inSearch ? Icons.close : Icons.search),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.filter_alt_outlined),
            itemBuilder: (context) {
              return controller
                  .getColumnsUser()
                  .entries
                  .map((item) => PopupMenuItem(
                        value: item.value,
                        child: Text(item.key),
                      ))
                  .toList();
            },
            initialValue: field,
            onSelected: (value) {
              // Pega o valor do filtro que ele selecionou e coloca no field
              setState(() {
                field = value;
              });
            },
          )
        ],
        automaticallyImplyLeading: false,
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
        child: StreamBuilder<QuerySnapshot<WorkRoute>>(
          stream: streamWorkRoutes,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done &&
                snapshot.connectionState != ConnectionState.active) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if ((!snapshot.hasData || snapshot.data!.docs.isEmpty) &&
                inSearch) {
              return const Card(
                elevation: 0,
                child: Center(
                  child: Text("Não há Rotas de Serviço"),
                ),
              );
            }

            final List<QueryDocumentSnapshot<WorkRoute>> workRouteData =
                !snapshot.hasData ? [] : snapshot.data!.docs;

            DateTime today = DateTime.now();

            // Dias para usar no filtro
            DateTime initalOfDay = DateTime(today.year, today.month, today.day);
            DateTime endOfDay =
                DateTime(today.year, today.month, today.day, 23, 59, 59);

            final actualWorkRoutes = workRouteData.where((element) {
              DateTime dataElemento = element.data().toDate.toDate();
              return dataElemento.isAfter(initalOfDay) &&
                  dataElemento.isBefore(endOfDay);
            }).toList();

            final previousWorkRoutes = workRouteData.where((element) {
              DateTime dataElemento = element.data().toDate.toDate();
              return dataElemento.isBefore(initalOfDay);
            }).toList();

            if (!inSearch) {
              return SizedBox(
                height: screen.height,
                width: screen.width,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 10,
                        ),
                        child: ExpansionPanelList(
                          animationDuration: Durations.medium4,
                          elevation: 4,
                          expansionCallback: (panelIndex, isExpanded) {
                            setState(() {
                              switch (panelIndex) {
                                case 0:
                                  showDayRoute = isExpanded;
                                  break;
                                case 1:
                                  showPreviousRoutes = isExpanded;
                                  break;
                              }
                            });
                          },
                          children: [
                            ExpansionPanel(
                              canTapOnHeader: true,
                              headerBuilder: (context, isExpanded) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: expandedWidth,
                                        height: 30,
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Rotas de serviços atuais",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              body: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 8),
                                child: actualWorkRoutes.isNotEmpty
                                    ? SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          itemCount: actualWorkRoutes.length,
                                          itemBuilder: (context, index) {
                                            QueryDocumentSnapshot<Person>?
                                                routeUser = user.firstWhere(
                                              (element) =>
                                                  element.id ==
                                                  actualWorkRoutes[index]
                                                      .data()
                                                      .uid,
                                            );

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                  AppRoutes.workRouteOrders,
                                                  arguments:
                                                      actualWorkRoutes[index]
                                                          .id,
                                                );
                                              },
                                              child: Card(
                                                elevation: 0,
                                                color: Colors.grey[200],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8,
                                                    horizontal: 4,
                                                  ),
                                                  child: ListTile(
                                                    leading: SizedBox(
                                                      width: 90,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          actualWorkRoutes[
                                                                      index]
                                                                  .data()
                                                                  .finish
                                                              ? const Icon(
                                                                  Icons
                                                                      .check_circle_outline_outlined,
                                                                  size: 32,
                                                                  color: Colors
                                                                      .green,
                                                                )
                                                              : const Icon(
                                                                  Icons
                                                                      .watch_later_outlined,
                                                                  size: 32,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                          Text(
                                                            actualWorkRoutes[
                                                                        index]
                                                                    .data()
                                                                    .finish
                                                                ? "Finalizado"
                                                                : "Pendente",
                                                            style: theme
                                                                .textTheme
                                                                .labelSmall!
                                                                .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    title: Text(
                                                      routeUser.data().name,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: Text(
                                                        dateFormat.format(
                                                            actualWorkRoutes[
                                                                    index]
                                                                .data()
                                                                .toDate
                                                                .toDate())),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: Text(
                                            "Não há rotas de serviços atuais")),
                              ),
                              isExpanded: showDayRoute,
                            ),
                            ExpansionPanel(
                              headerBuilder: (context, isExpanded) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: expandedWidth,
                                        height: 30,
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Rotas de serviços anteriores",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              body: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 8),
                                child: previousWorkRoutes.isNotEmpty
                                    ? SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          itemCount: previousWorkRoutes.length,
                                          itemBuilder: (context, index) {
                                            QueryDocumentSnapshot<Person>?
                                                routeUser = user.firstWhere(
                                              (element) =>
                                                  element.id ==
                                                  previousWorkRoutes[index]
                                                      .data()
                                                      .uid,
                                            );

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                  AppRoutes.workRouteOrders,
                                                  arguments:
                                                      previousWorkRoutes[index]
                                                          .id,
                                                );
                                              },
                                              child: Card(
                                                color: Colors.grey[200],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8,
                                                    horizontal: 4,
                                                  ),
                                                  child: ListTile(
                                                    leading: SizedBox(
                                                      width: 90,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          previousWorkRoutes[
                                                                      index]
                                                                  .data()
                                                                  .finish
                                                              ? const Icon(
                                                                  Icons
                                                                      .check_circle_outline_outlined,
                                                                  size: 32,
                                                                  color: Colors
                                                                      .green,
                                                                )
                                                              : const Icon(
                                                                  Icons
                                                                      .watch_later_outlined,
                                                                  size: 32,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                          Text(
                                                            previousWorkRoutes[
                                                                        index]
                                                                    .data()
                                                                    .finish
                                                                ? "Finalizado"
                                                                : "Pendente",
                                                            style: theme
                                                                .textTheme
                                                                .labelSmall!
                                                                .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    title: Text(
                                                      routeUser.data().name,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: Text(
                                                        dateFormat.format(
                                                            previousWorkRoutes[
                                                                    index]
                                                                .data()
                                                                .toDate
                                                                .toDate())),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: Text(
                                            "Não há rotas de serviços anteriores")),
                              ),
                              isExpanded: showPreviousRoutes,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            // return
            return Card(
              elevation: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: ListView.builder(
                  itemCount: workRouteData.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot<Person>? routeUser = user.firstWhere(
                      (element) =>
                          element.id == workRouteData[index].data().uid,
                    );

                    return Column(
                      children: [
                        Dismissible(
                          direction: DismissDirection.endToStart,
                          key: Key(workRouteData[index].id +
                              DateTime.now().toString()),
                          background: Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            controller.delete(workRouteData[index].id);
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.workRouteOrders,
                                arguments: workRouteData[index].id,
                              );
                            },
                            child: Card(
                              color: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 90,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        workRouteData[index].data().finish
                                            ? const Icon(
                                                Icons
                                                    .check_circle_outline_outlined,
                                                size: 32,
                                                color: Colors.green,
                                              )
                                            : const Icon(
                                                Icons.watch_later_outlined,
                                                size: 32,
                                                color: Colors.grey,
                                              ),
                                        Text(
                                          workRouteData[index].data().finish
                                              ? "Finalizado"
                                              : "Pendente",
                                          style: theme.textTheme.labelSmall!
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    routeUser.data().name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(dateFormat.format(
                                      workRouteData[index]
                                          .data()
                                          .toDate
                                          .toDate())),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
