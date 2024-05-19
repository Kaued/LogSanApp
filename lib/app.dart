import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logsan_app/Pages/layout.dart';
import 'package:logsan_app/Pages/login.dart';
import 'package:logsan_app/Repositories/auth_repository.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class App extends StatelessWidget {
  App({super.key});
  final _authRepository = AuthRepository.instance;

  String defineInitialRoute() {
    if (_authRepository.isAuthenticated()) {
      return AppRoutes.layout;
    }

    return AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: defineInitialRoute(),
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
        AppRoutes.layout: (context) => const Layout(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale("pt", "BR")],
    );
  }
}
