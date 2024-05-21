import 'package:flutter/material.dart';
import 'package:logsan_app/Utils/app_routes.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({
    super.key,
    this.onChanged,
  });

  final Function(String)? onChanged;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  var selectedPage = 0;
  var pages = {
    0: "",
    1: AppRoutes.userList,
    2: "",
    3: AppRoutes.listServiceOrder,
    4: "",
  };

  @override
  Widget build(BuildContext context) {
  
    return BottomNavigationBar(
      fixedColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      currentIndex: selectedPage,
      onTap: (index) => {
        setState(() {
          selectedPage = index;
        }),
        widget.onChanged!(pages[index]!)
        // Navigator.of(context).pushNamed(pages[index]!)
      },
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
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
      ],
    );
  }
}
