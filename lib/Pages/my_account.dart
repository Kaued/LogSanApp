import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final authController = AuthController.instance;

  Future<void> _logout(context) async {
    var isSuccessLogout = await authController.logout();

    if (isSuccessLogout) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      )
    );
  }
}