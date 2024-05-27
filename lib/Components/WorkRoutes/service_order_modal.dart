import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Components/loading_positioned.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/service_order.dart';

class ServiceOrderModal extends StatefulWidget {
  const ServiceOrderModal({super.key});

  @override
  State<ServiceOrderModal> createState() => _ServiceOrderModalState();
}

class _ServiceOrderModalState extends State<ServiceOrderModal> {
  final TextEditingController _searchController = TextEditingController();
  final WorkRouteController _workRouteController = WorkRouteController.instance;
  Timer? _debounce;
  List<QueryDocumentSnapshot<ServiceOrder>> serviceOrders = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
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
    );

    setState(() {
      serviceOrders = serviceOrderResponse;
      loading = false;
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
                    LoadingPositioned(loading: loading),
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
                                    return ListTile(
                                      title: Text(serviceOrder.referenceNumber),
                                      subtitle: Text(serviceOrder.address.city),
                                      onTap: () {
                                        Navigator.pop(context, serviceOrder);
                                      },
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    )
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
