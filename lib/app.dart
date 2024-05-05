import 'package:flutter/material.dart';
import 'package:logsan_app/Pages/list_service_order.dart';
import 'package:logsan_app/Pages/home.dart';
import 'package:logsan_app/Pages/login.dart';
import 'package:logsan_app/Pages/service_order_form.dart';
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
        textTheme: ThemeData.light().textTheme.copyWith(
              titleLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
      ),
      routes: {
        AppRoutes.login: (context) => const Login(),
        AppRoutes.listServiceOrder: (context) => const ListServiceOrder(),
        AppRoutes.serviceOrderForm: (context) => const ServiceOrderForm(),
        AppRoutes.home: (context) => const Home(),
      },
    );
  }
}
