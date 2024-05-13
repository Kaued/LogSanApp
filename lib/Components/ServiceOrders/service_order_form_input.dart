import 'package:flutter/material.dart';

class ServiceOrderFormInput extends StatelessWidget {
  const ServiceOrderFormInput({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.validator,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
  });

  final String labelText;
  final String? initialValue;
  final String hintText;
  final String? Function(String?) validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}
