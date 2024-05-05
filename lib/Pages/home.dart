import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final authController = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => authController.logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Text("teste"),
    );
  }
}
