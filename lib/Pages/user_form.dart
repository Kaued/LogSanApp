import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/user_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key, this.arguments});

  final FormArguments<Person?>? arguments;
  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _checkConfiguration() => true;
  Person? user;

  final UserController _controller = UserController.instance;

  // Key do formulário
  final formKey = GlobalKey<FormState>();

  // Variaveis dos campos do formulário
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final tipoUsuario = TextEditingController();
  bool isAdmin = true;

  final Map<String, bool> typeUser = {
    "Administrador": true,
    "Comum": false,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      if (widget.arguments != null &&
          !widget.arguments!.isAddMode &&
          widget.arguments!.values != null) {
        user = widget.arguments!.values!;
        nome.text = user!.name;
        email.text = user!.email;
      }
    });
  }

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      final emailText = email.text;
      final nomeText = nome.text;

      if (widget.arguments == null || widget.arguments!.isAddMode) {
        final senhaText = senha.text;
        try {
          await _controller.create(
              emailText, senhaText, nomeText, isAdmin, false);
        } catch (error) {}

        return;
      }

      try {
        await _controller.update(widget.arguments!.id!,
            email: emailText, name: nomeText, isAdmin: isAdmin);
      } catch (e) {}

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Regex do email - validação
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return Scaffold(
      appBar: AppBar(
        actions: const [],
        title: const Text(
          'Adicionar usuário',
        ),
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: nome,
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um nome';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um e-mail';
                      }
                      if (!regex.hasMatch(value)) {
                        return 'Por favor, insira um e-mail válido';
                      }
                      return null;
                    },
                  ),
                ),
                widget.arguments == null || widget.arguments!.isAddMode
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: senha,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Senha",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira uma senha';
                            }
                            if (value.length < 8) {
                              return 'Por favor, insira uma senha válida';
                            }
                            return null;
                          },
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, insira o tipo de usuário';
                          }
                          return null;
                        },
                        value: user == null
                            ? typeUser.values.first
                            : user!.isAdmin,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Tipo de Ordem de Serviço",
                        ),
                        items: typeUser.entries.map<DropdownMenuItem>((value) {
                          return DropdownMenuItem(
                            value: value.value,
                            child: Text(value.key),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            isAdmin = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    child: const Text("Cadastrar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
