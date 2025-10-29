import 'package:flutter/material.dart';
import '../1_event/screens/event_list_screen.dart';
import '../3_favorites/screens/favorites_screen.dart';
import '../4_converter/screens/converter_screen.dart';
import '../5_profile/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    EventListScreen(), // Tab 0: Home (List Event)
    const FavoritesScreen(),  // Tab 1: Favorites
    const ConverterScreen(),  // Tab 2: Converter
    const ProfileScreen(),    // Tab 3: Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan screen yang sedang aktif
      body: _screens[_selectedIndex],
      
      // Definisikan Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        // --- Ini penting untuk tema gelap agar rapi ---
        type: BottomNavigationBarType.fixed, // Agar 4 item muat
        backgroundColor: Theme.of(context).cardTheme.color, // Warna dari tema
        selectedItemColor: Theme.of(context).colorScheme.primary, // Warna Aksen
        unselectedItemColor: Colors.grey[600],
        // ------------------------------------------

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Converter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}