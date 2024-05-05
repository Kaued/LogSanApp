import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/type_order.dart';

import '../Components/ServiceOrders/address_modal.dart';
import '../Components/ServiceOrders/service_order_form_input.dart';

class ServiceOrderForm extends StatefulWidget {
  const ServiceOrderForm({super.key});

  @override
  State<ServiceOrderForm> createState() => _ServiceOrderFormState();
}

class _ServiceOrderFormState extends State<ServiceOrderForm> {
  final ServiceOrderController controller = ServiceOrderController.instance;
  List<QueryDocumentSnapshot<TypeOrder>> typeOrders = [];

  @override
  void initState() {
    super.initState();
    list();
  }

  void list() async {
    final response = await controller.getTypeOrders();

    setState(() {
      typeOrders = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Ordem de Serviço"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    ServiceOrderFormInput(
                      labelText: "Numero de Referência",
                      hintText: "O numero de referência da ordem de serviço",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "O numero de referência deve ser preenchido";
                        }
                        return null;
                      },
                    ),
                    ServiceOrderFormInput(
                      hintText:
                          "O estabelecimento que a ordem de serviço pertence",
                      labelText: "Estabelecimento",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "O estabelcimento ser informado";
                        }
                        return null;
                      },
                    ),
                    ServiceOrderFormInput(
                      labelText: "Horário de Atendimento",
                      hintText:
                          "O horário de atendimento que a ordem de serviço pertence",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "O horário de atendimento deve ser informado";
                        }
                        return null;
                      },
                    ),
                    ServiceOrderFormInput(
                      labelText: "Responsável",
                      hintText:
                          "O responsável do estabelecimento que a ordem de serviço pertence",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "O responsável do estabelecimento deve ser informado";
                        }
                        return null;
                      },
                    ),
                    ServiceOrderFormInput(
                      labelText: "Telefone",
                      hintText:
                          "O responsável do estabelecimento que a ordem de serviço pertence",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "O responsável do estabelecimento deve ser informado";
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DropdownButtonFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "O Tipo de Ordem de Serviço deve ser preenchido";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Tipo de Ordem de Serviço",
                        ),
                        items: typeOrders.map((typeOrder) {
                          return DropdownMenuItem(
                            value: typeOrder.id,
                            child: Text(typeOrder.data().name),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                    Row(
                      children: [
                        const Text("Endereço"),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => AddressModal(
                                onSaved: (p0) => print(p0),
                              ),
                            );
                          },
                          child: const Text("Definir Endereço"),
                        )
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () {
                          formKey.currentState!.validate();
                        },
                        child: const Text("teste"))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
