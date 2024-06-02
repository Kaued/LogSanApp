import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logsan_app/Components/ServiceOrders/service_order_form_input.dart';
import 'package:logsan_app/Models/equipment.dart';

class EquipmentModal extends StatefulWidget {
  const EquipmentModal({super.key, required this.onSaved, this.formValues});

  final Function(Equipment) onSaved;
  final Equipment? formValues;

  @override
  State<EquipmentModal> createState() => _EquipmentModalState();
}

class _EquipmentModalState extends State<EquipmentModal> {
  final _formKey = GlobalKey<FormState>();
  Equipment equipment = Equipment(
    logicalNumber: "",
    model: "",
    producer: "",
    serial: "",
  );

  @override
  void initState() {
    equipment = widget.formValues ?? equipment;
    super.initState();
  }

  void saveForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.onSaved(equipment);
      Navigator.of(context).pop();
    }
  }

  String? validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return "Este campo é obrigatório.";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 400,
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
                    Icons.add_business_outlined,
                    color: Colors.white,
                  ),
                  Text(
                    "Definir Equipamento a Instalar",
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
                    SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Column(
                            children: [
                              ServiceOrderFormInput(
                                initialValue: equipment.logicalNumber,
                                labelText: "Número Lógico",
                                hintText: "Número lógico do equipamento",
                                onSaved: (value) => setState(() {
                                  equipment.logicalNumber = value ?? "";
                                }),
                                validator: validateRequiredField,
                              ),
                              ServiceOrderFormInput(
                                initialValue: equipment.serial,
                                labelText: "Serial",
                                hintText: "Serial do equipamento",
                                onSaved: (value) => setState(() {
                                  equipment.serial = value ?? "";
                                }),
                                validator: validateRequiredField,
                              ),
                              ServiceOrderFormInput(
                                initialValue: equipment.model,
                                labelText: "Modelo",
                                hintText: "Modelo do equipamento",
                                onSaved: (value) => setState(() {
                                  equipment.model = value ?? "";
                                }),
                                validator: validateRequiredField,
                              ),
                              ServiceOrderFormInput(
                                labelText: "Fabricante",
                                initialValue: equipment.producer,
                                hintText: "Fabricante do equipamento",
                                onSaved: (value) => setState(() {
                                  equipment.producer = value ?? "";
                                }),
                                validator: validateRequiredField,
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
                                    onPressed: () => saveForm(context),
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
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
