import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'status_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Daftar Halaman yang akan ditampilkan
  final List<Widget> _screens = [
    const HomeScreen(),
    const StatusScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue.shade100,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu), 
              selectedIcon: Icon(Icons.restaurant_menu, color: Color(0xFF3B82F6)),
              label: 'Jadwal Menu'
            ),
            NavigationDestination(
              icon: Icon(Icons.local_shipping_outlined), 
              selectedIcon: Icon(Icons.local_shipping, color: Color(0xFF3B82F6)),
              label: 'Status'
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline), 
              selectedIcon: Icon(Icons.person, color: Color(0xFF3B82F6)),
              label: 'Profil'
            ),
          ],
        ),
      ),
    );
  }
}