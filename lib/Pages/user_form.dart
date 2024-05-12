import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  // Key do formulário
  final formKey = GlobalKey<FormState>();

  // Variaveis dos campos do formulário
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final tipoUsuario = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Regex do email - validação
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    final arguments = ModalRoute.of(context)?.settings.arguments as FormArguments<Person>;
    
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: senha,
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: tipoUsuario,
                    decoration: InputDecoration(
                      labelText: "Tipo de usuário",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value!.isEmpty) {
                        return 'Por favor, insira o tipo de usuário';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Cadastrar"),
                    onPressed: () {
                      // Valida o formulário quando o botão é pressionado.
                      if (formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enviando dados')),
                        );
                        // Aqui você pode enviar os dados do formulário para onde quer que precise.
                      }
                    },
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
