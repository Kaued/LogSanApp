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
        // Se tá vazio manda tudo
        if (value.text.isEmpty) {
          return users.toList();
        }
        // Se não, filtra
        return users.where((element) => element
            .data()
            .name
            .toLowerCase()
            .contains(value.text.toLowerCase()));
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
          hintText: "Selecione o usuário",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
