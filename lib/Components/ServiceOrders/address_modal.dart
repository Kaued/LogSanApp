import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Utils/Classes/address.dart';
import 'package:logsan_app/Utils/alerts.dart';

import 'service_order_form_input.dart';

class AddressModal extends StatefulWidget {
  const AddressModal({super.key, required this.onSaved});

  final Function(Address) onSaved;
  @override
  State<AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  final ServiceOrderController controller = ServiceOrderController.instance;
  Address address = Address(
    cep: "",
    street: "",
    neighborhood: "",
    city: "",
    state: "",
  );
  bool loading = false;

  final List<String> stateAbbreviations = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  void getAddress(String cep, BuildContext context) async {
    final String filteredCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (filteredCep.isNotEmpty) {
      setState(() {
        loading = true;
      });

      try {
        final addressResponse = await controller.getAddress(cep);
        setState(() {
          address = addressResponse;
        });
      } catch (e) {
        final error = e as Exception;

        if (context.mounted) {
          final String errorMessage = error.toString().split(":")[1];

          ScaffoldMessenger.of(context).showSnackBar(
            Alerts.errorMessage(
              context: context,
              message: errorMessage,
              title: "Verifique o Cep",
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();

    void saveForm() {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        widget.onSaved(address);
        Navigator.of(context).pop();
      }
    }

    return SizedBox(
      height: 460,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: theme.colorScheme.secondary,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.house,
                    color: Colors.white,
                  ),
                  Text(
                    "Definir Endereço",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 390,
              child: Stack(
                children: [
                  loading
                      ? Container(
                          color: Colors.black38,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container(),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            ServiceOrderFormInput(
                              initialValue: address.cep,
                              hintText: "Digite o Cep",
                              labelText: "CEP",
                              onFieldSubmitted: (value) =>
                                  getAddress(value, context),
                              onSaved: (value) => address.cep = value ?? "",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "O CEP deve ser informado";
                                }
                                return null;
                              },
                            ),
                            ServiceOrderFormInput(
                              initialValue: address.street,
                              labelText: "Rua",
                              onSaved: (value) => address.street = value ?? "",
                              hintText: "Rua do estabelecimento",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "A Rua deve ser informada.";
                                }
                                return null;
                              },
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: ServiceOrderFormInput(
                                    initialValue: address.neighborhood,
                                    labelText: "Bairro",
                                    onSaved: (value) =>
                                        address.neighborhood = value ?? "",
                                    hintText: "Bairro do estabelecimento",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "O Bairro deve ser informado";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ServiceOrderFormInput(
                                      onSaved: (value) => address.number =
                                          value == null
                                              ? 0
                                              : int.tryParse(value),
                                      labelText: "Número",
                                      hintText: "Número do estabelecimento",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "O Número deve ser informado";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: ServiceOrderFormInput(
                                    initialValue: address.city,
                                    labelText: "Cidade",
                                    onSaved: (value) =>
                                        address.city = value ?? "",
                                    hintText: "Cidade do estabelecimento",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "A Cidade deve ser informada";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 14),
                                    child: DropdownButtonFormField<String>(
                                      value: address.state.isEmpty
                                          ? null
                                          : address.state,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Estado",
                                        hintText: "Estado do estabelecimento",
                                      ),
                                      items: stateAbbreviations
                                          .map((state) => DropdownMenuItem(
                                                value: state,
                                                child: Text(state),
                                              ))
                                          .toList(),
                                      onChanged: (value) => address.state =
                                          value ?? address.state,
                                      onSaved: (value) =>
                                          address.state = value ?? "",
                                      validator: (value) {
                                        if (value == null) {
                                          return "O Estado deve ser informado";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ServiceOrderFormInput(
                              initialValue: address.complement,
                              hintText: "Complemento do estabelecimento",
                              onSaved: (value) =>
                                  address.complement = value ?? "",
                              labelText: "Complemento",
                              onFieldSubmitted: (value) =>
                                  getAddress(value, context),
                              validator: (value) {
                                return null;
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 20,
                                      ),
                                    ),
                                    child: Text(
                                      "Canelar",
                                      style:
                                          theme.textTheme.titleMedium!.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: saveForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: Text(
                                    "Salvar",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
