import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projeto_a1/controllers/avaliacao_controller.dart';
import 'package:projeto_a1/controllers/refeicao_controller.dart';
import 'package:projeto_a1/controllers/restaurante_controller.dart';
import 'package:projeto_a1/repositorios/avaliacao_repositorio.dart';
import 'package:projeto_a1/repositorios/refeicao_repositorio.dart';
import 'package:projeto_a1/repositorios/restaurante_repositorio.dart';
import 'package:projeto_a1/servicos/avaliacao_servico.dart';
import 'package:projeto_a1/servicos/pdf_servico.dart';
import 'package:projeto_a1/servicos/refeicao_servico.dart';
import 'package:projeto_a1/servicos/restaurante_servico.dart';
import 'package:projeto_a1/telas/avaliacoes_tela.dart';
import 'package:projeto_a1/telas/refeicoes_tela.dart';
import 'package:projeto_a1/telas/restaurante_tela.dart';
import 'package:projeto_a1/telas/login_tela.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Instancia as dependências uma única vez na raiz da aplicação.
  final pdfServico = PdfServico();

  final restauranteRepo = RestauranteRepositorio();
  final refeicaoRepo = RefeicaoRepositorio();
  final avaliacaoRepo = AvaliacaoRepositorio();

  final restauranteServico = RestauranteServico(restauranteRepo);
  final refeicaoServico = RefeicaoServico(refeicaoRepo);
  final avaliacaoServico = AvaliacaoServico(avaliacaoRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RestauranteController(restauranteServico, pdfServico),
        ),
        ChangeNotifierProvider(
          create: (_) => RefeicaoController(refeicaoServico, pdfServico),
        ),
        ChangeNotifierProvider(
          create: (_) => AvaliacaoController(avaliacaoServico, pdfServico),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Michelin',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _user = data.session?.user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const LoginTela();
    }
    return const NavigatorPage();
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
    const AvaliacoesTela(),
    const RefeicoesTela(),
    const RestauranteTela(),
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            tooltip: 'Sair',
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
            label: 'Avaliações',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Refeições',
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
