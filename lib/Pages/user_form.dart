import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logsan_app/Controllers/user_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _checkConfiguration() => true;
  FormArguments<Person?>? arguments;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_checkConfiguration()) {
        setState(() {
          arguments = ModalRoute.of(context)?.settings.arguments
              as FormArguments<Person?>?;
          if (arguments != null &&
              !arguments!.isAddMode &&
              arguments!.values != null) {
            user = arguments!.values!;
            nome.text = user!.name;
            email.text = user!.email;
          }
        });
      }
    });
  }

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      final emailText = email.text;
      final nomeText = nome.text;

      if (arguments == null || arguments!.isAddMode) {
        final senhaText = senha.text;
        try {
          await _controller.create(
              emailText, senhaText, nomeText, isAdmin, false);
        } catch (error) {}

        return;
      }

      try {
        await _controller.update(arguments!.id!,
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
        actions: [],
        title: Text(
          'Adicionar usuário',
        ),
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: nome,
                    decoration: InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value!.isEmpty) {
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
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value!.isEmpty) {
                        return 'Por favor, insira um e-mail';
                      }
                      if (!regex.hasMatch(value)) {
                        return 'Por favor, insira um e-mail válido';
                      }
                      return null;
                    },
                  ),
                ),
                arguments == null || arguments!.isAddMode
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: senha,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Senha",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value!.isEmpty) {
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
                            child: Text(value.key),
                            value: value.value,
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
                Container(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Cadastrar"),
                    onPressed: onSubmit,
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
