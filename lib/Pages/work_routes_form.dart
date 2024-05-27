import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Components/WorkRoutes/service_order_modal.dart';
import 'package:logsan_app/Components/WorkRoutes/work_route_input.dart';
import 'package:logsan_app/Components/chip_form.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';

import '../Components/WorkRoutes/user_autocomplete.dart';

class WorkRouteForm extends StatefulWidget {
  const WorkRouteForm({
    super.key,
    this.arguments,
  });

  final FormArguments<WorkRoute?>? arguments;

  @override
  State<WorkRouteForm> createState() => _WorkRouteFormState();
}

class _WorkRouteFormState extends State<WorkRouteForm> {
  final controller = WorkRouteController.instance;
  final dateFormatBr = DateFormat('dd/MM/yyyy');
  List<QueryDocumentSnapshot<Person>> users = [];
  String userInitialValue = "";

  WorkRoute workRoute = WorkRoute(
    toDate: Timestamp.now(),
    uid: "VzRrPCKWYVebUJTichuszItMf6v2",
    deleted: false,
    finish: false,
  );

  List<ServiceOrder> serviceOrders = [];

  bool _checkConfiguration() => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final usersResponse = await controller.getUsers();

    if (widget.arguments != null && !widget.arguments!.isAddMode) {
      setState(() {
        users = usersResponse;
        workRoute = widget.arguments!.values!;
        userInitialValue = users
            .firstWhere((element) => element.id == workRoute.uid)
            .data()
            .name;
      });
    }

    setState(() {
      users = usersResponse;
      userInitialValue = users
          .firstWhere((element) => element.data().uid == workRoute.uid)
          .data()
          .name;
    });
  }

  void showServiceOrderModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const ServiceOrderModal();
      },
    );
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Campo é obrigatório";
    }
    return null;
  }

  String _displayOptions(QueryDocumentSnapshot<Person> option) {
    return option.data().name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;
    final formKey = GlobalKey<FormState>();

    Future<void> selectDate() async {
      formKey.currentState!.save();

      DateTime? date = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: workRoute.toDate.toDate(),
        currentDate: DateTime.now(),
      );

      if (date != null) {
        setState(() {
          workRoute.toDate = Timestamp.fromDate(date);
        });
      }
    }

    void onSubmit() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Rota de Serviço",
              style: theme.textTheme.titleMedium!.copyWith(
                color: Colors.white,
              ),
            ),
            ChipForm(arguments: widget.arguments)
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              elevation: 0,
            ),
            child: Text(
              widget.arguments == null || widget.arguments!.isAddMode
                  ? "Cadastrar"
                  : "Editar",
            ),
          ),
        ],
      ),
      body: Container(
        height: screen.height,
        width: screen.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, .45],
              tileMode: TileMode.clamp),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.route),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Dados da Rota de Serviço",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Informações sobre a rota de serviço.",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            WorkRouteInput(
                              labelText: "Data da Rota",
                              hintText: "Data em que será realizada a rota.",
                              validator: validateDate,
                              onTap: selectDate,
                              readOnly: true,
                              initialValue: dateFormatBr.format(
                                workRoute.toDate.toDate(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: UserAutocomplete(
                                users: users,
                                onSelected: (value) {
                                  setState(() {
                                    workRoute.uid = value.id;
                                    userInitialValue = value.data().name;
                                  });
                                },
                                userInitialValue: userInitialValue,
                                displayOptions: _displayOptions,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.text_snippet_sharp),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Ordens de Serviço",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Ordens de serviço pertencente a rota de serviço.",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                showServiceOrderModal();
                              },
                              iconSize: 32,
                              icon: Icon(
                                Icons.add,
                                color: theme.colorScheme.secondary,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.only(top: 16),
                        child: ListView.builder(
                          itemCount: serviceOrders.length,
                          itemBuilder: (context, index) {
                            if (serviceOrders.isEmpty) {
                              return const Text(
                                  "Nenhuma ordem de serviço cadastrada.");
                            }

                            final serviceOrder = serviceOrders[index];

                            return ListTile(
                              title: Text(serviceOrder.referenceNumber),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
