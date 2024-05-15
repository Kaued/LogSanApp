import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Components/Equipments/equipment_modal.dart';
import 'package:logsan_app/Components/loading_positioned.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Models/equipment.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Utils/Classes/address.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/alerts.dart';

import '../Components/ServiceOrders/address_input.dart';
import '../Components/ServiceOrders/address_modal.dart';
import '../Components/ServiceOrders/equipments_form.dart';
import '../Components/ServiceOrders/service_order_form_input.dart';

class ServiceOrderForm extends StatefulWidget {
  const ServiceOrderForm({super.key, this.arguments});
  final FormArguments<ServiceOrder?>? arguments;

  @override
  State<ServiceOrderForm> createState() => _ServiceOrderFormState();
}

class _ServiceOrderFormState extends State<ServiceOrderForm> {
  final ServiceOrderController controller = ServiceOrderController.instance;
  final dateFormatBr = DateFormat('dd/MM/yyyy HH:mm');
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

    setState(() {
      if (widget.arguments != null &&
          !widget.arguments!.isAddMode &&
          widget.arguments!.values != null) {
        serviceOrder = widget.arguments!.values!;
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

    if (widget.arguments != null && !widget.arguments!.isAddMode) {
      setTypeOrder(serviceOrder.typeOrderId);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceOrderForm = GlobalKey<FormState>();
    final placeForm = GlobalKey<FormState>();
    final screen = MediaQuery.of(context).size;

    void onSubmit() async {
      if (serviceOrderForm.currentState!.validate() &&
          placeForm.currentState!.validate()) {
        serviceOrderForm.currentState!.save();
        placeForm.currentState!.save();

        setState(() {
          loading = true;
        });

        try {
          if (widget.arguments == null || widget.arguments!.isAddMode) {
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
              id: widget.arguments!.id!,
              needInstallEquipment: needInstallEquipment,
              needRemoveEquipment: needRemoveEquipment,
              installEquipment: installEquipment,
              removeEquipment: removeEquipment,
            );
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              Alerts.successMessage(
                  context: context,
                  message: "Operação realizada com sucesso.",
                  title: "Sucesso"),
            );
            Navigator.of(context).pop();
          }
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Alerts.errorMessage(
              context: context,
              message:
                  "Verifique se todos os campos forma preenchidos corretamente.",
              title: "Verifique os campos."),
        );
      }
    }

    void showModalAddress() {
      serviceOrderForm.currentState!.save();
      placeForm.currentState!.save();

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
      serviceOrderForm.currentState!.save();
      placeForm.currentState!.save();

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
      serviceOrderForm.currentState!.save();
      placeForm.currentState!.save();

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
      serviceOrderForm.currentState!.save();
      placeForm.currentState!.save();

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
      placeForm.currentState!.save();
      serviceOrderForm.currentState!.save();

      setTypeOrder(value);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments == null || widget.arguments!.isAddMode
              ? "Nova Ordem de Serviço"
              : "Editar Ordem de Serviço",
        ),
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
                child: ExpansionPanelList(
                  animationDuration: Durations.medium4,
                  expansionCallback: (panelIndex, isExpanded) {
                    serviceOrderForm.currentState!.save();
                    placeForm.currentState!.save();

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
                      body: Form(
                        key: serviceOrderForm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ServiceOrderFormInput(
                                initialValue: serviceOrder.referenceNumber,
                                labelText: "Numero de Referência",
                                onSaved: (value) => setState(() {
                                  serviceOrder.referenceNumber = value ?? "";
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
                                initialValue: dateFormatBr
                                    .format(serviceOrder.maxDate.toDate()),
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
                                      onSaved: (value) => setState(() {
                                        serviceOrder.typeOrderId = value ?? "";
                                      }),
                                      value: serviceOrder.typeOrderId.isEmpty
                                          ? null
                                          : serviceOrder.typeOrderId,
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
                                      onChanged: onChangeTypeOrder,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                      body: Form(
                        key: placeForm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  serviceOrder.openingHours = value ?? "";
                                }),
                              ),
                              ServiceOrderFormInput(
                                initialValue: serviceOrder.responsible,
                                labelText: "Responsável",
                                onSaved: (value) => setState(() {
                                  serviceOrder.responsible = value ?? "";
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
                                  serviceOrder.phoneNumber = value ?? "";
                                }),
                              ),
                              AddressInput(
                                onShowModal: showModalAddress,
                                address: serviceOrder.address,
                              )
                            ],
                          ),
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
                      body: EquipmentsForm(
                        needInstallEquipment: needInstallEquipment,
                        installEquipment: installEquipment,
                        needRemoveEquipment: needRemoveEquipment,
                        removeEquipment: removeEquipment,
                        onShowModalInstallEquipment: showModalInstallEquipment,
                        onShowModalRemoveEquipment: showModalRemoveEquipment,
                      ),
                      isExpanded: showEquipmentInformation,
                    )
                  ],
                ),
              ),
            ),
            LoadingPositioned(
              loading: loading,
              top: 0,
            )
          ],
        ),
      ),
    );
  }
}
