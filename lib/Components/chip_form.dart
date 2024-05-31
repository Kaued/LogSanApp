import 'package:flutter/material.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';

class ChipForm extends StatelessWidget {
  const ChipForm({
    super.key,
    required this.arguments,
  });

  final FormArguments<dynamic>? arguments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
      ),
      child: Chip(
        label: Text(
          arguments == null || arguments!.isAddMode ? "new" : "edit",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        backgroundColor: arguments == null || arguments!.isAddMode
            ? Colors.green
            : Colors.amber[900],
      ),
    );
  }
}
