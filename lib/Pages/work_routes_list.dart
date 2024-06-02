import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logsan_app/Components/WorkRoutes/work_routes_search.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class WorkRoutesList extends StatefulWidget {
  const WorkRoutesList({super.key});

  @override
  State<WorkRoutesList> createState() => _WorkRoutesListState();
}

class _WorkRoutesListState extends State<WorkRoutesList> {
  bool inSearch = false;
  final controller = WorkRouteController.instance;
  // Lista das work routes que atualiza por si
  Stream<QuerySnapshot<WorkRoute>>? streamWorkRoutes = const Stream.empty();
  Timer? _debounce;
  String field = "";
  List<QueryDocumentSnapshot<Person>> user = [];
  final dateFormat = DateFormat("dd/MM/yyyy");

  @override
  void initState() {
    super.initState();
    list();

    setState(() {
      // Já seleciona um valor pra quando for pesquisar
      field = controller.getColumns().entries.first.value;
    });
  }

  void list() async {
    var workRoutes = controller.getWorkRoutes();
    var usersData = await controller.getUsers();

    setState(() {
      streamWorkRoutes = workRoutes;
      user = usersData;
    });
  }

  void toggleSearch() {
    if (inSearch) {
      var workRoutes = controller.getWorkRoutes();

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

  void _onSearchChanged(String query) {
    // Se o timer pra pesquisar estiver ativo
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(seconds: 1), () {
      var workRoutes = controller.getWorkRoutes(field: field, value: query);
      setState(() {
        streamWorkRoutes = workRoutes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: inSearch
            ? WorkRoutesSearch(field: field, onSearch: _onSearchChanged)
            : Text(
                "Rotas de Serviços",
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
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
                  .getColumns()
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.workRouteForm,
            arguments: FormArguments<WorkRoute?>(isAddMode: true),
          );
        },
        child: const Icon(Icons.add),
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
              return Container(
                child: const Card(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Card(
                child: Center(
                  child: Text("Não há Rotas de Serviço"),
                ),
              );
            }

            final workRouteData = snapshot.data!.docs;

            // return
            return Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: ListView.builder(
                  itemCount: workRouteData.length,
                  itemBuilder: (context, index) {
                    print(workRouteData[index].data());
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
                              Navigator.pushNamed(
                                context,
                                AppRoutes.workRouteForm,
                                arguments: FormArguments<WorkRoute?>(
                                  isAddMode: false,
                                  values: workRouteData[index].data(),
                                  id: workRouteData[index].id,
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 3,
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
