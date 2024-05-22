import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logsan_app/Components/chip_form.dart';
import 'package:logsan_app/Controllers/work_route_controller.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';

class WorkRouteForm extends StatefulWidget {
  const WorkRouteForm({
    super.key,
    this.arguments,
  });

  final FormArguments<WorkRoute?>? arguments;

  @override
  State<WorkRouteForm> createState() => _WorkRouteFormState();
}

class _WorkRouteFormState extends State<WorkRouteForm> {
  final controller = WorkRouteController.instance;
  final dateFormatBr = DateFormat('dd/MM/yyyy HH:mm');
  final formKey = GlobalKey<FormState>();
  bool _checkConfiguration() => true;

  void onSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Row(
            children: [
              Text(
                "Rota de Serviço",
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
              ChipForm(arguments: widget.arguments)
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                elevation: 0,
              ),
              child: Text(
                widget.arguments == null || widget.arguments!.isAddMode
                    ? "Cadastrar"
                    : "Editar",
              ),
            ),
          ],
        ),
        body: Container(
          height: screen.height,
          width: screen.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .65],
                tileMode: TileMode.clamp),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          child: const Card(),
        ));
  }
}
