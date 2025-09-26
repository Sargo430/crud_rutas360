import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';



class Base extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const Base({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final sidebarController = SidebarXController(selectedIndex: navigationShell.currentIndex, extended: true);
    sidebarController.addListener(() {
      if (sidebarController.selectedIndex != navigationShell.currentIndex) {
        navigationShell.goBranch(sidebarController.selectedIndex);
      }
    });
    return Scaffold(
      appBar: AppBar( 
        title: const Text('CRUD Rutas 360',
         style: TextStyle(color: Colors.white)), 
         backgroundColor: const Color(0xFF4D67AE), 
        ),
      body:Row(
        children: [
          SidebarX(
            controller: sidebarController,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xF1F1F1F1),
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
              selectedTextStyle: const TextStyle(color: Colors.black),
              itemTextPadding: const EdgeInsets.only(left: 30),
              selectedItemTextPadding: const EdgeInsets.only(left: 30),
              itemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Color(0xFF4D67AE).withValues(alpha: 0.3), width: 1),
                color: Color(0xFF4D67AE).withValues(alpha: 0.1),
              ),
              iconTheme: IconThemeData(
                color: Colors.black.withValues(alpha: 0.7),
                size: 20,
              ),
              selectedIconTheme: const IconThemeData(
                color: Colors.black,
                size: 20,
              ),
            ),
            extendedTheme: const SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: Color(0xF1F1F1F1),
              ),
            ),
            items: const [
              SidebarXItem(icon: Icons.home, label: 'Home'),
              SidebarXItem(icon: Icons.route, label: 'Rutas'),
              SidebarXItem(icon: Icons.location_on, label: 'Users'),
              SidebarXItem(icon: Icons.category, label: 'Categorías'),
              SidebarXItem(icon: Icons.hiking, label: 'Actividades'),
            ],
          ),
          
          Expanded(
            child: navigationShell,

            ),
        ],
      )
    );
  }
}