import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/layout_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';
import 'package:logsan_app/Pages/list_service_order.dart';
import 'package:logsan_app/Pages/service_order_form.dart';
import 'package:logsan_app/Pages/user_form.dart';
import 'package:logsan_app/Pages/user_list.dart';
import 'package:logsan_app/Pages/work_routes_list.dart';
import 'package:logsan_app/Pages/work_routes_form.dart';
import 'package:logsan_app/Repositories/auth_repository.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';
import 'package:logsan_app/Utils/app_routes.dart';

const Color searchBackground = Color(0xFFFAFAFA);

// Tela home
Widget _buildHomeScreen(context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                color: searchBackground,
                width: 329,
                child: const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                    ),
                    hintText: 'Pesquisar',
                    hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.25)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.filter_alt_outlined,
              ),
            ),
          ],
        ),
      ),
    ),
    body: const Stack(
      children: [Text('home')],
    ),
  );
}

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  final LayoutController _layoutController = LayoutController.instance;
  String initialPage = AppRoutes.login;
  bool _checkConfiguration() => true;

  @override
  void initState() {
    super.initState();

    if (!_layoutController.isAuthenticated()) {
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
                  routeSetting.name!, context, routeSetting.arguments);
            },
            transitionDuration: const Duration(seconds: 0),
          ),
        ),
        bottomNavigationBar: BottomBar(
          onChanged: (String route) {
            Navigator.pushNamed(
              navigatorKey.currentContext!,
              route,
            );
          },
        ),
      ),
    );
  }

  Widget getCurrentPage(
      String currentRoute, BuildContext context, Object? arguments) {
    switch (currentRoute) {
      case AppRoutes.home:
        return _buildHomeScreen(context);
      case AppRoutes.userList:
        return const UserList();
      case AppRoutes.userForm:
        return UserForm(
          arguments: arguments as FormArguments<Person?>?,
        );
      case AppRoutes.listServiceOrder:
        return const ListServiceOrder();
      case AppRoutes.serviceOrderForm:
        return ServiceOrderForm(
          arguments: arguments as FormArguments<ServiceOrder?>?,
        );
      case AppRoutes.workRoutesList:
        return const WorkRoutesList();
      case AppRoutes.workRouteForm:
        return WorkRouteForm(
            arguments: arguments as FormArguments<WorkRoute?>?);
      default:
        return _buildHomeScreen(context);
    }
  }
}
