import 'package:flutter/material.dart';
import 'package:logsan_app/Pages/casquinha.dart';
import 'package:logsan_app/Pages/login.dart';
import 'package:logsan_app/Pages/user_form.dart';
import 'package:logsan_app/Pages/user_list.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoutes.login,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: const Color(0xff638CF4),
              secondary: const Color(0xffFFAB00),
            ),
      ),
      routes: {
        AppRoutes.login: (context) => const Login(),
        AppRoutes.userForm: (context) => const UserForm(),
        AppRoutes.userList: (context) => const UserList(),
        AppRoutes.casquinha: (context) => Casquinha()
      },
    );
  }
}
