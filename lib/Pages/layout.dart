import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';
import 'package:logsan_app/Pages/list_service_order.dart';
import 'package:logsan_app/Pages/service_order_form.dart';
import 'package:logsan_app/Pages/user_form.dart';
import 'package:logsan_app/Pages/user_list.dart';
import 'package:logsan_app/Pages/work_routes_list.dart';
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
  final AuthRepository authRepository = AuthRepository.instance;
  bool _checkConfiguration() => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_checkConfiguration()) {
        if (!authRepository.isAuthenticated()) {
          print(FirebaseAuth.instance.currentUser);
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Navigator(
          key: navigatorKey,
          initialRoute: AppRoutes.login,
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
      default:
        return _buildHomeScreen(context);
    }
  }
}
