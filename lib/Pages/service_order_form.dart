import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Components/Equipments/equipment_modal.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/equipment.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Utils/Classes/address.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/alerts.dart';

import '../Components/ServiceOrders/address_modal.dart';
import '../Components/ServiceOrders/service_order_form_input.dart';

class ServiceOrderForm extends StatefulWidget {
  const ServiceOrderForm({super.key});

  @override
  State<ServiceOrderForm> createState() => _ServiceOrderFormState();
}

class _ServiceOrderFormState extends State<ServiceOrderForm> {
  final ServiceOrderController controller = ServiceOrderController.instance;
  final dateFormatBr = DateFormat('dd/MM/yyyy HH:mm');
  FormArguments<ServiceOrder?>? arguments;
  bool _checkConfiguration() => true;

  List<QueryDocumentSnapshot<TypeOrder>> typeOrders = [];
  ServiceOrder serviceOrder = ServiceOrder(
    openingHours: "",
    phoneNumber: "",
    placeName: "",
    referenceNumber: "",
    responsible: "",
    typeOrderId: "",
    maxDate: Timestamp.now(),
    address: Address(
        cep: "",
        neighborhood: "",
        street: "",
        complement: "",
        city: "",
        state: ""),
  );

  Equipment? installEquipment;
  Equipment? removeEquipment;
  bool showServiceInformation = true;
  bool showCompanyInformation = true;
  bool showEquipmentInformation = true;
  bool needInstallEquipment = false;
  bool needRemoveEquipment = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_checkConfiguration()) {
        setState(() {
          arguments = ModalRoute.of(context)?.settings.arguments
              as FormArguments<ServiceOrder>?;
          if (arguments != null &&
              !arguments!.isAddMode &&
              arguments!.values != null) {
            serviceOrder = arguments!.values!;
          }
        });
      }
    });

    list();
  }

  void setTypeOrder(value) {
    final typeSelect = typeOrders.firstWhere((type) => type.id == value);

    setState(() {
      needInstallEquipment = false;
      needRemoveEquipment = false;
      serviceOrder.typeOrderId = value;
    });

    if (typeSelect.data().name == "Instalação" ||
        typeSelect.data().name == "Troca") {
      setState(() {
        needInstallEquipment = true;
      });
    }

    if (typeSelect.data().name == "Desinstalação" ||
        typeSelect.data().name == "Troca") {
      setState(() {
        needRemoveEquipment = true;
      });
    }
  }

  void list() async {
    setState(() {
      loading = true;
    });

    final response = await controller.getTypeOrders();

    if (serviceOrder.installEquipment != null) {
      final installEquipmentRequest =
          await controller.findEquipment(serviceOrder.installEquipment!);

      setState(() {
        installEquipment = installEquipmentRequest.data();
      });
    }

    if (serviceOrder.removeEquipment != null) {
      final removeEquipmentRequest =
          await controller.findEquipment(serviceOrder.removeEquipment!);

      setState(() {
        removeEquipment = removeEquipmentRequest.data();
      });
    }

    setState(() {
      typeOrders = response;
    });

    if (arguments != null && !arguments!.isAddMode) {
      setTypeOrder(serviceOrder.typeOrderId);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;

    void onSubmit() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        setState(() {
          loading = true;
        });
        try {
          if (arguments == null || arguments!.isAddMode) {
            await controller.createServiceOrder(
              serviceOrder: serviceOrder,
              needInstallEquipment: needInstallEquipment,
              needRemoveEquipment: needRemoveEquipment,
              installEquipment: installEquipment,
              removeEquipment: removeEquipment,
            );
          } else {
            await controller.updateServiceOrder(
              serviceOrder: serviceOrder,
              id: arguments!.id!,
              needInstallEquipment: needInstallEquipment,
              needRemoveEquipment: needRemoveEquipment,
              installEquipment: installEquipment,
              removeEquipment: removeEquipment,
            );
          }
          Navigator.of(context).pop();
        } catch (e) {
          final error = e as Exception;

          if (context.mounted) {
            final String errorMessage = error.toString().split(":")[1];
            ScaffoldMessenger.of(context).showSnackBar(
              Alerts.errorMessage(
                context: context,
                message: errorMessage,
                title: "Existem campos inválidos!",
              ),
            );
          }
        } finally {
          setState(() {
            loading = false;
          });
        }
      }
    }

    void showModalAddress() {
      formKey.currentState!.save();
      showModalBottomSheet(
        context: context,
        builder: (context) => AddressModal(
          onSaved: (value) => setState(() {
            serviceOrder.address = value;
          }),
          formValues: serviceOrder.address,
        ),
        backgroundColor: Colors.transparent,
      );
    }

    void showModalInstallEquipment() {
      formKey.currentState!.save();
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

    void showModalRemoveEquipment() {
      formKey.currentState!.save();
      showModalBottomSheet(
        context: context,
        builder: (context) => EquipmentModal(
          onSaved: (value) {
            setState(() {
              removeEquipment = value;
            });
          },
          formValues: removeEquipment,
        ),
        backgroundColor: Colors.transparent,
      );
    }

    Future<void> selectDate() async {
      formKey.currentState!.save();

      DateTime? date = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: DateTime.now(),
        currentDate: DateTime.now(),
      );

      if (context.mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (date != null && time != null) {
          final dateTimeSelect =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          setState(() {
            serviceOrder.maxDate = Timestamp.fromDate(dateTimeSelect);
          });
        }
      }
    }

    void onChangeTypeOrder(value) {
      formKey.currentState!.save();
      setTypeOrder(value);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Ordem de Serviço"),
        actions: [
          IconButton(onPressed: onSubmit, icon: const Icon(Icons.save))
        ],
      ),
      body: SizedBox(
        height: screen.height,
        width: screen.width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                child: Column(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          ExpansionPanelList(
                            animationDuration: Durations.medium2,
                            expansionCallback: (panelIndex, isExpanded) {
                              formKey.currentState!.save();
                              setState(() {
                                switch (panelIndex) {
                                  case 0:
                                    showServiceInformation = isExpanded;
                                    break;
                                  case 1:
                                    showCompanyInformation = isExpanded;
                                    break;
                                  case 2:
                                  default:
                                    showEquipmentInformation = isExpanded;
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
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.article,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Dados da Ordem de Serviço",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                body: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ServiceOrderFormInput(
                                        initialValue:
                                            serviceOrder.referenceNumber,
                                        labelText: "Numero de Referência",
                                        onSaved: (value) => setState(() {
                                          serviceOrder.referenceNumber =
                                              value ?? "";
                                        }),
                                        hintText:
                                            "O numero de referência da ordem de serviço",
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "O numero de referência deve ser preenchido";
                                          }
                                          return null;
                                        },
                                      ),
                                      ServiceOrderFormInput(
                                        initialValue: dateFormatBr.format(
                                            serviceOrder.maxDate.toDate()),
                                        readOnly: true,
                                        onTap: selectDate,
                                        labelText: "Data de Vencimento",
                                        hintText:
                                            "A data de vencimento da ordem de serviço",
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "O numero de referência deve ser preenchido";
                                          }
                                          return null;
                                        },
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "O Tipo de Ordem de Serviço deve ser preenchido";
                                                }
                                                return null;
                                              },
                                              onSaved: (value) => setState(() {
                                                serviceOrder.typeOrderId =
                                                    value ?? "";
                                              }),
                                              value: serviceOrder
                                                      .typeOrderId.isEmpty
                                                  ? null
                                                  : serviceOrder.typeOrderId,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText:
                                                    "Tipo de Ordem de Serviço",
                                              ),
                                              items:
                                                  typeOrders.map((typeOrder) {
                                                return DropdownMenuItem(
                                                  value: typeOrder.id,
                                                  child: Text(
                                                      typeOrder.data().name),
                                                );
                                              }).toList(),
                                              onChanged: onChangeTypeOrder,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                isExpanded: showServiceInformation,
                              ),
                              ExpansionPanel(
                                canTapOnHeader: true,
                                headerBuilder: (context, isExpanded) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 15,
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.apartment,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Dados do Estabelecimento",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                body: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ServiceOrderFormInput(
                                        initialValue: serviceOrder.placeName,
                                        hintText:
                                            "O estabelecimento que a ordem de serviço pertence",
                                        labelText: "Nome do Estabelecimento",
                                        onSaved: (value) => setState(() {
                                          serviceOrder.placeName = value ?? "";
                                        }),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "O estabelecimento deve ser informado";
                                          }
                                          return null;
                                        },
                                      ),
                                      ServiceOrderFormInput(
                                        initialValue: serviceOrder.openingHours,
                                        labelText: "Horário de Atendimento",
                                        hintText:
                                            "O horário de atendimento que a ordem de serviço pertence",
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "O horário de atendimento deve ser informado";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => setState(() {
                                          serviceOrder.openingHours =
                                              value ?? "";
                                        }),
                                      ),
                                      ServiceOrderFormInput(
                                        initialValue: serviceOrder.responsible,
                                        labelText: "Responsável",
                                        onSaved: (value) => setState(() {
                                          serviceOrder.responsible =
                                              value ?? "";
                                        }),
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
                                        initialValue: serviceOrder.phoneNumber,
                                        labelText: "Telefone",
                                        hintText:
                                            "O responsável do estabelecimento que a ordem de serviço pertence",
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "O responsável do estabelecimento deve ser informado";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => setState(() {
                                          serviceOrder.phoneNumber =
                                              value ?? "";
                                        }),
                                      ),
                                      if (serviceOrder.address.cep.isEmpty)
                                        Row(
                                          children: [
                                            const Flexible(
                                              flex: 2,
                                              child: Divider(),
                                            ),
                                            Flexible(
                                              flex: 4,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      showModalAddress(),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 8,
                                                      horizontal: 4,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.add_circle,
                                                          color: Colors.white,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8),
                                                          child: Text(
                                                            "Adicionar Endereço",
                                                            style: theme
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Flexible(
                                              flex: 2,
                                              child: Divider(),
                                            )
                                          ],
                                        )
                                      else
                                        GestureDetector(
                                          onTap: () => showModalAddress(),
                                          child: Card(
                                            elevation: 3,
                                            color: Colors.grey[200],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 4,
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  "${serviceOrder.address.street}, ${serviceOrder.address.number?.toString()} - ${serviceOrder.address.neighborhood}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                leading: Icon(
                                                  Icons.location_on_outlined,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  size: 32,
                                                ),
                                                subtitle: Text(
                                                    "${serviceOrder.address.city} - ${serviceOrder.address.cep}"),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                isExpanded: showCompanyInformation,
                              ),
                              ExpansionPanel(
                                canTapOnHeader: true,
                                headerBuilder: (context, isExpanded) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 15,
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.ad_units,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Equipamentos",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                body: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              "Equipamento a Instalar",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: theme.colorScheme.primary,
                                            ),
                                          )
                                        ],
                                      ),
                                      needInstallEquipment
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: installEquipment == null
                                                  ? Row(
                                                      children: [
                                                        const Expanded(
                                                            child: Divider()),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              showModalInstallEquipment(),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 8,
                                                              horizontal: 4,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .add_circle,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8),
                                                                  child: Text(
                                                                    "Adicionar Equipamento",
                                                                    style: theme
                                                                        .textTheme
                                                                        .titleMedium!
                                                                        .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            child: Divider()),
                                                      ],
                                                    )
                                                  : GestureDetector(
                                                      onTap: () =>
                                                          showModalInstallEquipment(),
                                                      child: Card(
                                                        elevation: 3,
                                                        color: Colors.grey[200],
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 8,
                                                            horizontal: 4,
                                                          ),
                                                          child: ListTile(
                                                            title: Text(
                                                              "${installEquipment!.serial} - ${installEquipment!.model}",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            leading: Icon(
                                                              Icons
                                                                  .install_mobile,
                                                              color: theme
                                                                  .colorScheme
                                                                  .primary,
                                                              size: 32,
                                                            ),
                                                            subtitle: Text(
                                                                "${installEquipment!.logicalNumber} |${installEquipment!.producer}"),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: Card(
                                                color: Colors.grey[200],
                                                elevation: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  child: Center(
                                                    child: Text(
                                                      "Não há necessidade desse equipamento nesse serviço",
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              "Equipamento a Remover",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    theme.colorScheme.secondary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          )
                                        ],
                                      ),
                                      needRemoveEquipment
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: removeEquipment == null
                                                  ? Row(
                                                      children: [
                                                        const Expanded(
                                                            child: Divider()),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              showModalRemoveEquipment(),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 8,
                                                              horizontal: 4,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .add_circle,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8),
                                                                  child: Text(
                                                                    "Adicionar Equipamento",
                                                                    style: theme
                                                                        .textTheme
                                                                        .titleMedium!
                                                                        .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            child: Divider()),
                                                      ],
                                                    )
                                                  : GestureDetector(
                                                      onTap: () =>
                                                          showModalRemoveEquipment(),
                                                      child: Card(
                                                        elevation: 3,
                                                        color: Colors.grey[200],
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 8,
                                                            horizontal: 4,
                                                          ),
                                                          child: ListTile(
                                                            title: Text(
                                                              "${removeEquipment!.serial} - ${removeEquipment!.model}",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            leading: Icon(
                                                              Icons
                                                                  .install_mobile,
                                                              color: theme
                                                                  .colorScheme
                                                                  .secondary,
                                                              size: 32,
                                                            ),
                                                            subtitle: Text(
                                                                "${removeEquipment!.logicalNumber} |${removeEquipment!.producer}"),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: Card(
                                                color: Colors.grey[200],
                                                elevation: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  child: Center(
                                                    child: Text(
                                                      "Não há necessidade desse equipamento nesse serviço",
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                isExpanded: showEquipmentInformation,
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            loading
                ? Positioned(
                    top: 0,
                    child: Container(
                      height: screen.height,
                      width: screen.width,
                      color: Colors.black38,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
