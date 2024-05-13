import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Utils/app_routes.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';

import '../Components/ServiceOrders/service_order_list.dart';

class ListServiceOrder extends StatefulWidget {
  const ListServiceOrder({super.key});

  @override
  State<ListServiceOrder> createState() => _ListServiceOrderState();
}

class _ListServiceOrderState extends State<ListServiceOrder> {
  bool inSearch = false;
  final controller = ServiceOrderController.instance;
  Timer? _debounce;
  String field = "";

  Stream<QuerySnapshot<ServiceOrder>> streamServiceOrders =
      const Stream.empty();
  List<QueryDocumentSnapshot<TypeOrder>> typeOrders = [];

  @override
  void initState() {
    super.initState();
    list();

    setState(() {
      field = controller.getColumns().entries.first.value;
    });
  }

  void list() async {
    var orders = controller.getServiceOrders();
    var type = await controller.getTypeOrders();

    setState(() {
      streamServiceOrders = orders;
      typeOrders = type;
    });
  }

  void toggleSearch() {
    if (inSearch) {
      var orders = controller.getServiceOrders();

      setState(() {
        inSearch = !inSearch;
        streamServiceOrders = orders;
      });

      return;
    }

    setState(() {
      inSearch = !inSearch;
    });
  }

  @override
  void dispose() {
    super.dispose();

    _debounce?.cancel();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(seconds: 1), () {
      var orders = controller.getServiceOrders(field: field, value: query);

      setState(() {
        streamServiceOrders = orders;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Animate(
          effects: const [FadeEffect()],
          child: inSearch
              ? TextField(
                  decoration: const InputDecoration(
                    hintText: "Pesquisar",
                    fillColor: Colors.white,
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: _onSearchChanged,
                )
              : const Text("Ordens de Serviço"),
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
              setState(() {
                field = value;
              });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRoutes.serviceOrderForm,
            arguments: FormArguments(isAddMode: true),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: StreamBuilder<QuerySnapshot<ServiceOrder>>(
          stream: streamServiceOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done &&
                snapshot.connectionState != ConnectionState.active) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("Não há Ordens de Serviço"),
              );
            }

            final serviceOrders = snapshot.data!.docs;

            return ServiceOrderList(
              serviceOrders: serviceOrders,
              typeOrders: typeOrders,
            );
          },
        ),
      ),
    );
  }
}
