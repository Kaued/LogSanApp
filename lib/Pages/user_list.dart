import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/user_controller.dart';
import 'package:logsan_app/Models/person.dart';
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
        title: const Text("Listar Usuários"),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(
          "/user-form",
          arguments: FormArguments<Person>(
            isAddMode: true,
          ),
        ),
        mini: true,
        child: const Icon(Icons.add),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) {
                        controller.delete(users[index].id);
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  "/user-form",
                                  arguments: FormArguments<Person>(
                                    isAddMode: false,
                                    values: users[index].data(),
                                    id: users[index].id,
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(users[index].data().name),
                                subtitle: Text(
                                  users[index].data().isAdmin
                                      ? 'admin'
                                      : 'comum',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 0)
                  ],
                );
              },
            );
          }),
    );
  }
}
