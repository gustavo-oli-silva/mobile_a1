import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:projeto_a1/telas/avaliacoes_tela.dart';
import 'package:projeto_a1/telas/refeicoes_tela.dart';
import 'package:projeto_a1/telas/restaurante_tela.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: NavigatorPage(),
    );
  }
}

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
    AvaliacoesTela(),
    RefeicoesTela(),
    RestauranteTela(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Michelin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2, 
          ),
        ),
        centerTitle: true, 
        backgroundColor: Colors.red.shade800, 
        elevation: 4, 
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16), 
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex,
        onDestinationSelected: (value) => setState(() {
          _selectedPageIndex = value;
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.star), 
            label: 'Avaliaçoes'
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Refeiçoes',
          ),
          NavigationDestination(
            icon: Icon(Icons.food_bank),
            label: 'Restaurantes',
          ),
        ],
      ),
    );
  }
}
