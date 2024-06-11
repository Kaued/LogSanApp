import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';

class MyAccount extends StatefulWidget {
  final void Function() logout;

  const MyAccount({
    super.key,
    required this.logout,
  });

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final authController = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Animate(
          effects: const [FadeEffect()],
          child: Text(
            "Minha Conta",
            style: theme.textTheme.titleMedium!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              Colors.white,
            ],
            begin: const FractionalOffset(0, 0),
            end: const FractionalOffset(0, 1),
            stops: const [0, .65],
            tileMode: TileMode.clamp,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      authController.user.name,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  // text Logout and a logout icon
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      Text('Logout'),
                    ],
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
