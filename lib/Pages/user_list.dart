import 'package:flutter/material.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';

class User {
  final int id;
  final String name;
  final String type;

  User({required this.id, required this.name, required this.type});
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemplo de lista de usuários
    List<User> users = [
      User(id: 3, name: 'João', type: 'admin'),
      User(id: 3, name: 'Maria', type: 'comum'),
      User(id: 3, name: 'Pedro', type: 'comum'),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text("Listar Usuários"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed("/user-form"),
        mini: true,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Dismissible(
                key: Key(users[index].id.toString()),
                background: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete),
                  color: Colors.red,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/user-form", arguments: users[index]);
                        },
                        child: ListTile(
                          title: Text(users[index].name),
                          subtitle: Text(users[index].type.toLowerCase()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0,
              )
            ],
          );
        },
      ),
    );
  }
}
