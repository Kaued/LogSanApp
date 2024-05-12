import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';
import 'package:logsan_app/Controllers/user_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final authController = AuthController.instance;
  final userController = UserController.instance;

  Future<void> _logout(context) async {
    var isSuccessLogout = await authController.logout();

    if (isSuccessLogout) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  Future<void> _testAction() async {
    // print(userController.list());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IconButton(
        onPressed: () => _testAction(),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
