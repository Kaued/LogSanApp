import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Models/person.dart';

class UserAutocomplete extends StatelessWidget {
  final List<QueryDocumentSnapshot<Person>> users;
  final Function(QueryDocumentSnapshot<Person>) onSelected;
  final String userInitialValue;
  final String Function(QueryDocumentSnapshot<Person>) displayOptions;

  const UserAutocomplete({
    super.key,
    required this.users,
    required this.onSelected,
    required this.userInitialValue,
    required this.displayOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<QueryDocumentSnapshot<Person>>(
      displayStringForOption: displayOptions,
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) {
          return users.toList();
        }

        return users.where((element) {
          return element
              .data()
              .name
              .toLowerCase()
              .contains(value.text.toLowerCase());
        }).toList();
      },
      onSelected: onSelected,
      initialValue: TextEditingValue(text: userInitialValue),
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) =>
              TextFormField(
        controller: textEditingController,
        focusNode: focusNode,
        onFieldSubmitted: (value) {
          onFieldSubmitted();
        },
        decoration: const InputDecoration(
          labelText: "Usuário",
          hintText: "Selecione o usuário responsável pela rota.",
          border: OutlineInputBorder(),
        ),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 72,
            height: 48 * options.length.toDouble(),
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.toList()[index];
                return ListTile(
                  title: Text(option.data().name),
                  onTap: () {
                    onSelected(option);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
