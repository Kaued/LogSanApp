import 'package:flutter/material.dart';

class User {
  final String name;
  final String type;

  User({required this.name, required this.type});
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemplo de lista de usuários
    List<User> users = [
      User(name: 'João', type: 'Admin'),
      User(name: 'Maria', type: 'User'),
      User(name: 'Pedro', type: 'User'),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text("Listar Usuários"),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].name),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.route,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}
