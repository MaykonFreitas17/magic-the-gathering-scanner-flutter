import 'package:flutter/material.dart';
import 'core/app_theme.dart';

import 'features/home/home_view.dart';

void main() {
  runApp(const SolLensApp());
}

class SolLensApp extends StatelessWidget {
  const SolLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sol Lens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Lista de telas para cada aba
  static const List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    Center(
      child: Text(
        '📸 Aba do Scanner (Sol Lens)',
        style: TextStyle(fontSize: 24),
      ),
    ),
    Center(child: Text('🎴 Aba de Meus Decks', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sol Lens'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Busca'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Decks'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 90, 43, 5),
        onTap: _onItemTapped,
      ),
    );
  }
}
