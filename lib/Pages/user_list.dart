import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/user_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';

class User {
  final int id;
  final String name;
  final String type;

  User({required this.id, required this.name, required this.type});
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final controller = UserController.instance;
  Stream<QuerySnapshot<Person>> streamUser = const Stream.empty();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    list();
  }

  void list() async {
    final stream = controller.list();

    setState(() {
      streamUser = stream;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<QuerySnapshot<Person>>(
          stream: streamUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done &&
                snapshot.connectionState != ConnectionState.active) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("Não há usuário cadastrado"),
              );
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
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
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed("/user-form",
                                    arguments: FormArguments<Person>(isAddMode: false, values: users[index].data(), ));
                              },
                              child: ListTile(
                                title: Text(users[index].data().name),
                                subtitle: Text(
                                  users[index].data().isAdmin
                                      ? 'admin'
                                      : 'comum',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
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
            );
          }),
    );
  }
}
