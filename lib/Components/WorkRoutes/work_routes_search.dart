import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/person.dart';

class WorkRoutesSearch extends StatefulWidget {
  const WorkRoutesSearch(
      {super.key, required this.field, required this.onSearch});

  final String field;
  final void Function(String) onSearch;

  @override
  State<WorkRoutesSearch> createState() => _WorkRoutesSearchState();
}

class _WorkRoutesSearchState extends State<WorkRoutesSearch> {
  List<QueryDocumentSnapshot<Person>> user = [];
  final controller = WorkRouteController.instance;
  final dateFormat = DateFormat("dd/MM/yyyy");
  DateTime? date;
  final dateController = TextEditingController();
  final Map<String, bool> status = {"Pendente": false, "Finalizado": true};
  bool valueStatus = false;

  @override
  void initState() {
    super.initState();
    list();
  }

  void list() async {
    var users = await controller.getUsers();
    setState(() {
      user = users;
    });
  }

  // Pega o nome do user
  String displayOptions(QueryDocumentSnapshot<Person> user) {
    return user.data().name;
  }

  // Pesquisa as rotas do usuário que selecionou
  void onSelectUser(QueryDocumentSnapshot<Person> user) {
    widget.onSearch(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> selectDate() async {
      DateTime? date = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: DateTime.now(),
        currentDate: DateTime.now(),
      );

      if (date != null) {
        setState(() {
          this.date = date;
        });

        dateController.text = dateFormat.format(date);

        widget.onSearch(date.toIso8601String());
      }
    }

    if (widget.field == "uid") {
      return Autocomplete<QueryDocumentSnapshot<Person>>(
        // filtro
        optionsBuilder: (TextEditingValue value) {
          // Se tá vazio manda tudo
          if (value.text.isEmpty) {
            return user.toList();
          }
          // Se não, filtra
          return user.where((element) => element
              .data()
              .name
              .toLowerCase()
              .contains(value.text.toLowerCase()));
        },
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) =>
                TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (value) {
            onFieldSubmitted();
          },
          decoration: const InputDecoration(
            hintText: "Pesquisar",
            fillColor: Colors.white,
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        // Para cada opção na lista
        displayStringForOption: displayOptions,
        onSelected: onSelectUser,
      );
    } else if (widget.field == "to_date") {
      return TextField(
        decoration: const InputDecoration(
          hintText: "Selecione uma data",
          fillColor: Colors.white,
          hintStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
        controller: dateController,
        onTap: () => selectDate(),
        readOnly: true, //não da pra digitar a data
      );
    } else if (widget.field == "finish") {
      return ButtonTheme(
        alignedDropdown: true,
        child: SizedBox(
          width: double.infinity,
          child: DropdownButton<bool>(
            style: const TextStyle(color: Colors.white),
            dropdownColor: theme.colorScheme.primary,
            value: valueStatus,
            items: status.entries
                .map((e) => DropdownMenuItem<bool>(
                      value: e.value,
                      child: Text(e.key),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                valueStatus = value;
              });
              widget.onSearch(value ? '1' : '0');
            },
          ),
        ),
      );
    }

    return const Placeholder();
  }
}
