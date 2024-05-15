import 'package:flutter/material.dart';
import 'package:logsan_app/Utils/Classes/address.dart';

class AddressInput extends StatelessWidget {
  const AddressInput({
    super.key,
    required this.onShowModal,
    required this.address,
  });

  final Function() onShowModal;
  final Address address;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (address.cep.isEmpty) {
      return Row(
        children: [
          const Flexible(
            flex: 2,
            child: Divider(),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: ElevatedButton(
                onPressed: () => onShowModal(),
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
                          "Adicionar Endereço",
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: Colors.white,
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
      );
    }

    return GestureDetector(
      onTap: () => onShowModal(),
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
              "${address.street}, ${address.number?.toString()} - ${address.neighborhood}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: Icon(
              Icons.location_on_outlined,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            subtitle: Text("${address.city} - ${address.cep}"),
          ),
        ),
      ),
    );
  }
}
