import 'package:flutter/material.dart';
import 'package:projeto_a1/telas/avaliacoes_tela.dart';
import 'package:projeto_a1/telas/refeicoes_tela.dart';
import 'package:projeto_a1/telas/restaurante_tela.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
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
    RestauranteTela()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Michelin', 
        style: TextStyle(color: Colors.white)), 
        backgroundColor: Colors.red
        ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex,
        onDestinationSelected: (value) => setState(() {
          _selectedPageIndex = value;
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.star), label: 'Avaliaçoes'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Refeiçoes'),
          NavigationDestination(icon: Icon(Icons.food_bank), label: 'Restaurantes')
        ],
        ),
    );
  }
}

