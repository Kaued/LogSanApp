import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Components/loading_positioned.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';

class ServiceOrderModal extends StatefulWidget {
  const ServiceOrderModal({super.key, required this.chooseServiceOrders});

  final List<String> chooseServiceOrders;

  @override
  State<ServiceOrderModal> createState() => _ServiceOrderModalState();
}

class _ServiceOrderModalState extends State<ServiceOrderModal> {
  final TextEditingController _searchController = TextEditingController();
  final WorkRouteController _workRouteController = WorkRouteController.instance;
  Timer? _debounce;
  List<QueryDocumentSnapshot<ServiceOrder>> serviceOrders = [];
  List<QueryDocumentSnapshot<TypeOrder>> typeOrders = [];
  List<String> chooseServiceOrders = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      chooseServiceOrders = widget.chooseServiceOrders;
    });

    _loadServiceOrders();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _debounce?.cancel();
  }

  Future<void> _loadServiceOrders() async {
    setState(() {
      loading = true;
    });

    final serviceOrderResponse =
        await _workRouteController.getServiceOrderEnables(
      search: _searchController.text,
      chooseServiceOrders: widget.chooseServiceOrders,
    );

    serviceOrders.sort((a, b) {
      if (chooseServiceOrders.contains(a.id)) {
        return -1;
      }

      return 0;
    });

    final typeOrderResponse = await _workRouteController.getTypeOrders();

    setState(() {
      serviceOrders = serviceOrderResponse;
      typeOrders = typeOrderResponse;
      loading = false;
    });
  }

  void _onTouchServiceOrder(String id) {
    if (chooseServiceOrders.contains(id)) {
      setState(() {
        chooseServiceOrders.remove(id);
        serviceOrders.sort((a, b) {
          if (chooseServiceOrders.contains(a.id)) {
            if (chooseServiceOrders.contains(b.id)) {
              return 0;
            }
            return -1;
          }

          return 1;
        });
      });
      return;
    }

    setState(() {
      chooseServiceOrders.add(id);
      serviceOrders.sort((a, b) {
        if (chooseServiceOrders.contains(a.id)) {
          if (chooseServiceOrders.contains(b.id)) {
            return 0;
          }
          return -1;
        }

        return 1;
      });
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(seconds: 1), () async {
      setState(() {
        loading = true;
      });

      var orders = await _workRouteController.getServiceOrderEnables(
        search: query,
        chooseServiceOrders: widget.chooseServiceOrders,
      );

      setState(() {
        serviceOrders = orders;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 460,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: theme.colorScheme.secondary),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_rounded,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "Adicionar Ordem de Serviço",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                labelText: "Pesquisar",
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                hintText: "Buscar numero de referência",
                              ),
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                            ),
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                  itemCount: serviceOrders.length,
                                  itemBuilder: (context, index) {
                                    final serviceOrder =
                                        serviceOrders[index].data();
                                    final String id = serviceOrders[index].id;

                                    final typeOrder = typeOrders
                                        .firstWhere(
                                          (element) =>
                                              element.id ==
                                              serviceOrder.typeOrderId,
                                        )
                                        .data();

                                    IconData iconType =
                                        Icons.precision_manufacturing;

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
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                Text(
                                                  typeOrder.name,
                                                  style: theme
                                                      .textTheme.labelSmall!
                                                      .copyWith(
                                                    fontSize: 8,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          title: Text(
                                              serviceOrder.referenceNumber),
                                          subtitle: Text(
                                              "${serviceOrder.address.city} - ${serviceOrder.address.neighborhood}"),
                                          onTap: () {
                                            _onTouchServiceOrder(id);
                                          },
                                          trailing: Checkbox(
                                            value: chooseServiceOrders
                                                .contains(id),
                                            onChanged: (value) {
                                              _onTouchServiceOrder(id);
                                            },
                                          )),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                    LoadingPositioned(loading: loading),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
