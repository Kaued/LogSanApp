import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logsan_app/Components/loading_positioned.dart';
import 'package:logsan_app/Controllers/service_order_controller.dart';
import 'package:logsan_app/Utils/Classes/address.dart';
import 'package:logsan_app/Utils/alerts.dart';

import 'service_order_form_input.dart';

class AddressModal extends StatefulWidget {
  const AddressModal({
    super.key,
    required this.onSaved,
    this.formValues,
  });

  final Function(Address) onSaved;
  final Address? formValues;

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

  @override
  void initState() {
    address = widget.formValues ?? address;

    super.initState();
  }

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

  String? validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return "Este campo é obrigatório.";
    }

    return null;
  }

  String? validateNumberField(String? value) {
    if (value == null || value.isEmpty) {
      return "Este campo é obrigatório.";
    }

    if (int.tryParse(value) == null) {
      return "O valor informado deve ser um número";
    }

    return null;
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
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    LoadingPositioned(
                      loading: loading,
                    ),
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
                                onSaved: (value) => setState(() {
                                  address.cep = value ?? "";
                                }),
                                validator: validateRequiredField,
                              ),
                              ServiceOrderFormInput(
                                  initialValue: address.street,
                                  labelText: "Rua",
                                  onSaved: (value) => setState(() {
                                        address.street = value ?? "";
                                      }),
                                  hintText: "Rua do estabelecimento",
                                  validator: validateRequiredField),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: ServiceOrderFormInput(
                                      initialValue: address.neighborhood,
                                      labelText: "Bairro",
                                      onSaved: (value) => setState(() {
                                        address.neighborhood = value ?? "";
                                      }),
                                      hintText: "Bairro do estabelecimento",
                                      validator: validateRequiredField,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: ServiceOrderFormInput(
                                        onSaved: (value) => setState(() {
                                          address.number = value == null
                                              ? 0
                                              : int.tryParse(value);
                                        }),
                                        initialValue:
                                            address.number?.toString(),
                                        labelText: "Número",
                                        hintText: "Número do estabelecimento",
                                        validator: validateNumberField,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: ServiceOrderFormInput(
                                      initialValue: address.city,
                                      labelText: "Cidade",
                                      onSaved: (value) => setState(() {
                                        address.city = value ?? "";
                                      }),
                                      hintText: "Cidade do estabelecimento",
                                      validator: validateRequiredField,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, bottom: 14),
                                      child: DropdownButtonHideUnderline(
                                        child: ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButtonFormField<
                                                  String>(
                                              value: address.state.isEmpty
                                                  ? null
                                                  : address.state,
                                              decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: "Estado",
                                                  hintText:
                                                      "Estado do estabelecimento",
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 17,
                                                          horizontal: 10)),
                                              items: stateAbbreviations
                                                  .map((state) =>
                                                      DropdownMenuItem(
                                                        value: state,
                                                        child: Text(state),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) =>
                                                  address.state =
                                                      value ?? address.state,
                                              onSaved: (value) => setState(() {
                                                    address.state = value ?? "";
                                                  }),
                                              validator: validateRequiredField),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ServiceOrderFormInput(
                                initialValue: address.complement,
                                hintText: "Complemento do estabelecimento",
                                onSaved: (value) => setState(() {
                                  address.complement = value ?? "";
                                }),
                                labelText: "Complemento",
                                onFieldSubmitted: (value) =>
                                    getAddress(value, context),
                                validator: (value) => null,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 20,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(
                                              "Cancelar",
                                              style: theme
                                                  .textTheme.titleMedium!
                                                  .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: saveForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 20,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Text(
                                            "Salvar",
                                            style: theme.textTheme.titleMedium!
                                                .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
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
            ),
          ],
        ),
      ),
    );
  }
}
