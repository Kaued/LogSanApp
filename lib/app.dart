import 'package:flutter/material.dart';
import 'package:logsan_app/Pages/login.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {"/login": (context) => Login()},
      initialRoute: "/login",
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: false,
      ),
    );
  }
}
