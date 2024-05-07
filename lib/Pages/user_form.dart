import 'package:flutter/material.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text(
          'Adicionar usuário',
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Container(
          height: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Nome",
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Tipo de usuário",
                  border: OutlineInputBorder(),
                ),
              ),
              Container(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                    child: Text("Cadastrar"), onPressed: () => {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
