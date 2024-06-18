import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Components/WorkRoutes/list_service_order.dart';
import 'package:logsan_app/Components/WorkRoutes/service_order_modal.dart';
import 'package:logsan_app/Components/WorkRoutes/work_route_input.dart';
import 'package:logsan_app/Components/chip_form.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/alerts.dart';

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
  bool loading = false;

  WorkRoute workRoute = WorkRoute(
    toDate: Timestamp.now(),
    uid: "",
    deleted: false,
    finish: false,
  );

  List<QueryDocumentSnapshot<ServiceOrder>> serviceOrders = [];
  List<String> chooseServiceOrders = [];
  List<QueryDocumentSnapshot<TypeOrder>> typeOrders = [];

  bool _checkConfiguration() => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final usersResponse = await controller.getUsers();
    final typeOrdersResponse = await controller.getTypeOrders();

    if (widget.arguments != null && !widget.arguments!.isAddMode) {
      final ordersInRoute =
          await controller.getChooseServiceOrder(widget.arguments!.id!);

      setState(() {
        chooseServiceOrders = ordersInRoute;
        users = usersResponse;
        workRoute = widget.arguments!.values!;
        userInitialValue = users
            .firstWhere((element) => element.id == workRoute.uid)
            .data()
            .name;
        typeOrders = typeOrdersResponse;
      });

      await loadServiceOrders();

      return;
    }

    setState(() {
      users = usersResponse;
      typeOrders = typeOrdersResponse;
    });
  }

  Future<void> loadServiceOrders() async {
    if (chooseServiceOrders.isEmpty) {
      return;
    }

    final serviceOrdersResponse =
        await controller.getServiceOrdersById(chooseServiceOrders);

    setState(() {
      serviceOrders = serviceOrdersResponse;
    });
  }

  void onSaveChooseServiceOrders(List<String> serviceOrders) {
    setState(() {
      chooseServiceOrders = [...serviceOrders, ...chooseServiceOrders];
    });

    loadServiceOrders();
  }

  void showServiceOrderModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ServiceOrderModal(
          chooseServiceOrders: chooseServiceOrders,
          onSave: onSaveChooseServiceOrders,
        );
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

  void _removeSelectedServiceOrder(String id) {
    setState(() {
      chooseServiceOrders.remove(id);
      serviceOrders.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;
    final formKey = GlobalKey<FormState>();
    final double expandedWidth = screen.width - 144;
    const double expandedHeight = 70;

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
      if (formKey.currentState!.validate()) {
        if (workRoute.uid.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(Alerts.errorMessage(
              context: context,
              message: "É necessário informar o usuário",
              title: "Rota de Serviço Inválida"));
        }

        if (chooseServiceOrders.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(Alerts.errorMessage(
              context: context,
              message: "É necessário informar ao menos uma ordem de serviço",
              title: "Rota de Serviço Inválida"));
        }

        try {
          setState(() {
            loading = true;
          });

          if (widget.arguments != null && !widget.arguments!.isAddMode) {
            await controller.updateWorkRoute(
              workRoute: workRoute,
              chooseServiceOrder: chooseServiceOrders,
              id: widget.arguments!.id!,
            );

            if (context.mounted) {
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                Alerts.successMessage(
                    context: context,
                    message: "Rota de serviço editada com sucesso",
                    title: "Rota de Serviço"),
              );
            }
            return;
          }
          await controller.createWorkRoute(
              workRoute: workRoute, chooseServiceOrder: chooseServiceOrders);

          if (context.mounted) {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              Alerts.successMessage(
                  context: context,
                  message: "Rota de serviço criada com sucesso",
                  title: "Rota de Serviço"),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              Alerts.errorMessage(
                  context: context,
                  message: "Erro ao criar a rota de serviço",
                  title: "Rota de Serviço Inválida"),
            );
          }
        } finally {
          setState(() {
            loading = false;
          });
        }
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
        child: SingleChildScrollView(
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
                            Container(
                              width: expandedWidth,
                              height: expandedHeight,
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Dados da Rota de Serviço",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Informações sobre a rota de serviço.",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
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
                                child: SizedBox(
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.text_snippet_sharp),
                              Container(
                                width: expandedWidth,
                                height: expandedHeight,
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Ordens de Serviço",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "Ordens de serviço pertencente a rota de serviço.",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
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
                            height: screen.height * 0.2 + 16,
                            padding: const EdgeInsets.only(top: 16),
                            child: ServiceOrderListRoute(
                              chooseServiceOrders: chooseServiceOrders,
                              deleteServiceOrder: _removeSelectedServiceOrder,
                              serviceOrders: serviceOrders,
                              typeOrders: typeOrders,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
