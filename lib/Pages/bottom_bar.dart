import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class BottomBar extends StatefulWidget {
  final Function(String)? onChanged;

  const BottomBar({
    super.key,
    this.onChanged,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  var selectedPage = 0;
  final authController = AuthController.instance;
  var pages = {
    0: AppRoutes.home,
    1: AppRoutes.userList,
    2: AppRoutes.workRoutesList,
    3: AppRoutes.listServiceOrder,
    4: AppRoutes.myAccont,
  };

  @override
  void initState() {
    super.initState();

    setState(() {
      pages = authController.user.isAdmin
          ? {
              0: AppRoutes.home,
              1: AppRoutes.userList,
              2: AppRoutes.workRoutesList,
              3: AppRoutes.listServiceOrder,
              4: AppRoutes.myAccont,
            }
          : {
              0: AppRoutes.home,
              1: AppRoutes.myAccont,
              2: AppRoutes.workRoutesListUser,
            };
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        enableFeedback: false,
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        fixedColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        currentIndex: selectedPage,
        onTap: (index) => {
              setState(() {
                selectedPage = index;
              }),
              widget.onChanged!(pages[index]!)
            },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: authController.user.isAdmin
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.house,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.people,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.route,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.text_snippet_rounded,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                  ),
                  label: "",
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.house,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.route,
                  ),
                  label: "",
                ),
              ]);
  }
}
