import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:logsan_app/Components/Equipments/equipment_modal.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/equipment.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Utils/Classes/address.dart';

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
  Address? address;
  Equipment? installEquipment;

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
    final theme = Theme.of(context);

    void showModalAddress() {
      showModalBottomSheet(
        context: context,
        builder: (context) => AddressModal(
          onSaved: (value) => setState(() {
            address = value;
          }),
          formValues: address,
        ),
        backgroundColor: Colors.transparent,
      );
    }

    void showModalInstallEquipment() {
      showModalBottomSheet(
        context: context,
        builder: (context) => EquipmentModal(
          onSaved: (value) {
            setState(() {
              installEquipment = value;
            });
          },
          formValues: installEquipment,
        ),
        backgroundColor: Colors.transparent,
      );
    }

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
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonHideUnderline(
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              "Endereço",
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 5,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: address == null
                                  ? ElevatedButton(
                                      onPressed: () => showModalAddress(),
                                      child: const Text("Definir Endereço"),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        spellOut: true,
                                        children: [
                                          TextSpan(
                                            spellOut: true,
                                            text:
                                                "${address!.street}, ${address!.number?.toString()} - ${address!.neighborhood} ${address!.city} - ${address!.state}, ${address!.cep} ",
                                          ),
                                          TextSpan(
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                            text: "Mudar endereço",
                                            recognizer: TapGestureRecognizer()
                                              ..onTap =
                                                  () => showModalAddress(),
                                          )
                                        ],
                                      ),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Equipamento Instalar",
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => showModalInstallEquipment(),
                          child: const Text("Definir equipamento a instalar"),
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
