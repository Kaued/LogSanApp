import 'package:flutter/material.dart';
import 'package:logsan_app/Pages/bottom_bar.dart';
import 'package:logsan_app/Pages/user_form.dart';
import 'package:logsan_app/Pages/user_list.dart';
import 'package:logsan_app/Utils/app_routes.dart';

const Color searchBackground = Color(0xFFFAFAFA);

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
    body: Stack(
      children: [Text('home')],
    ),
  );
}

class Casquinha extends StatelessWidget {
  Casquinha({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Navigator(
          key: navigatorKey,
          initialRoute: AppRoutes.login,
          onGenerateRoute: (routeSetting) => PageRouteBuilder(
            pageBuilder: (ctx, ani, ani1) {
              return getCurrentPage(routeSetting.name!, context);
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

  Widget getCurrentPage(String currentRoute, BuildContext context) {
    switch (currentRoute) {
      case AppRoutes.home:
        return _buildHomeScreen(context);
      case AppRoutes.userList:
        return UserList();
      case AppRoutes.userForm:
        return UserForm();
      default:
        return _buildHomeScreen(context);
    }
  }
}
