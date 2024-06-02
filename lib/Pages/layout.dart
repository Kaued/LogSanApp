import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';
import 'package:logsan_app/Pages/home.dart';
import 'package:logsan_app/Pages/list_service_order.dart';
import 'package:logsan_app/Pages/my_account.dart';
import 'package:logsan_app/Pages/service_order_form.dart';
import 'package:logsan_app/Pages/user_form.dart';
import 'package:logsan_app/Pages/user_list.dart';
import 'package:logsan_app/Pages/work_routes_form.dart';
import 'package:logsan_app/Pages/work_routes_list.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  final authController = AuthController.instance;
  String initialPage = AppRoutes.login;
  bool _checkConfiguration() => true;

  @override
  void initState() {
    super.initState();

    if (!authController.isAuthenticated() || authController.user.uid.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_checkConfiguration()) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      });

      return;
    }

    setState(() {
      initialPage = AppRoutes.home;
    });
  }

  void logout() async {
    bool successLogout = await authController.logout();

    if (!successLogout) return;

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Navigator(
          key: navigatorKey,
          initialRoute: initialPage,
          onGenerateRoute: (routeSetting) => PageRouteBuilder(
            pageBuilder: (ctx, ani, ani1) {
              return getCurrentPage(
                routeSetting.name!,
                context,
                routeSetting.arguments,
              );
            },
            transitionDuration: const Duration(seconds: 0),
          ),
        ),
        bottomNavigationBar: BottomBar(
          onChanged: (String route) {
            navigatorKey.currentState!.pushReplacementNamed(route);
          },
        ),
      ),
    );
  }

  Widget getCurrentPage(
    String currentRoute,
    BuildContext context,
    Object? arguments,
  ) {
    switch (currentRoute) {
      case AppRoutes.home:
        return const Home();
      case AppRoutes.userList:
        return const UserList();
      case AppRoutes.userForm:
        return UserForm(arguments: arguments as FormArguments<Person?>?);
      case AppRoutes.listServiceOrder:
        return const ListServiceOrder();
      case AppRoutes.serviceOrderForm:
        return ServiceOrderForm(
          arguments: arguments as FormArguments<ServiceOrder?>?,
        );
      case AppRoutes.myAccont:
        return MyAccount(logout: logout);
      case AppRoutes.workRoutesList:
        return const WorkRoutesList();
      case AppRoutes.workRouteForm:
        return WorkRouteForm(
            arguments: arguments as FormArguments<WorkRoute?>?);
      default:
        return const Home();
    }
  }
}
