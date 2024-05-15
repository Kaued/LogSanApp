import 'package:flutter/material.dart';
import 'package:logsan_app/Models/equipment.dart';

class EquipmentsForm extends StatelessWidget {
  const EquipmentsForm({
    super.key,
    required this.needInstallEquipment,
    required this.installEquipment,
    required this.needRemoveEquipment,
    required this.removeEquipment,
    required this.onShowModalInstallEquipment,
    required this.onShowModalRemoveEquipment,
  });

  final bool needInstallEquipment;
  final Equipment? installEquipment;
  final bool needRemoveEquipment;
  final Equipment? removeEquipment;
  final Function() onShowModalInstallEquipment;
  final Function() onShowModalRemoveEquipment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Equipamento a Instalar",
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.primary,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: installEquipment == null
                      ? Row(
                          children: [
                            const Expanded(child: Divider()),
                            ElevatedButton(
                              onPressed: () => onShowModalInstallEquipment(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Adicionar Equipamento",
                                        style: theme.textTheme.titleMedium!
                                            .copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        )
                      : GestureDetector(
                          onTap: () => onShowModalInstallEquipment(),
                          child: Card(
                            elevation: 3,
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: ListTile(
                                title: Text(
                                  "${installEquipment!.serial} - ${installEquipment!.model}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.install_mobile,
                                  color: theme.colorScheme.primary,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Card(
                    color: Colors.grey[200],
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          "Não há necessidade desse equipamento nesse serviço",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
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
                  color: theme.colorScheme.secondary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Equipamento a Remover",
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: theme.colorScheme.secondary,
                ),
              )
            ],
          ),
          needRemoveEquipment
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: removeEquipment == null
                      ? Row(
                          children: [
                            const Expanded(child: Divider()),
                            ElevatedButton(
                              onPressed: () => onShowModalRemoveEquipment(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_circle,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Adicionar Equipamento",
                                        style: theme.textTheme.titleMedium!
                                            .copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        )
                      : GestureDetector(
                          onTap: () => onShowModalRemoveEquipment(),
                          child: Card(
                            elevation: 3,
                            color: Colors.grey[200],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: ListTile(
                                title: Text(
                                  "${removeEquipment!.serial} - ${removeEquipment!.model}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.install_mobile,
                                  color: theme.colorScheme.secondary,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Card(
                    color: Colors.grey[200],
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          "Não há necessidade desse equipamento nesse serviço",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
