import 'package:flutter/material.dart';
import 'package:logsan_app/Models/equipment.dart';

class EquipmentItem extends StatelessWidget {
  const EquipmentItem({
    super.key,
    required this.installEquipment,
    required this.removeEquipment,
  });

  final Equipment? installEquipment;
  final Equipment? removeEquipment;

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
          installEquipment != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
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
          removeEquipment != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
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
