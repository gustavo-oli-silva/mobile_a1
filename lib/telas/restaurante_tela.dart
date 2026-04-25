import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/repositorios/restaurante_repositorio.dart';
import 'package:projeto_a1/widgets/botao.dart';
import 'package:projeto_a1/widgets/restaurante_card.dart';
import 'package:projeto_a1/widgets/restaurante_modal.dart';

class RestauranteTela extends StatefulWidget {
  const RestauranteTela({super.key});

  @override
  State<RestauranteTela> createState() => _RestauranteTelaState();
}

class _RestauranteTelaState extends State<RestauranteTela> {
  final RestauranteRepositorio _repositorio = RestauranteRepositorio();
  List<Restaurante> restaurantes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarRestaurantes();
  }

  Future<void> _carregarRestaurantes() async {
    setState(() => _carregando = true);
    final lista = await _repositorio.listar();
    setState(() {
      restaurantes = lista;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      floatingActionButton: restaurantes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                _showRestauranteModal(context);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Adicionar',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            )
          : null,
      body: SizedBox(
        width: double.infinity,
        child: restaurantes.isNotEmpty ? _content() : _ifEmpty(context),
      ),
    );
  }

  Widget _content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: restaurantes.length,
            itemBuilder: (context, index) {
              final restaurante = restaurantes[index];
              return RestauranteCard(
                restaurante: restaurante,
                onEdit: () => _showRestauranteModal(context, restauranteExistente: restaurante),
                onDelete: () async {
                  if (restaurante.id != null) {
                    await _repositorio.deletar(restaurante.id!);
                    await _carregarRestaurantes();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _ifEmpty(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Nenhum restaurante encontrado...',
          style: TextStyle(fontSize: 40),
          textAlign: TextAlign.center,
        ),
        Botao(
          texto: 'Registre um agora mesmo!',
          onPressed: () {
            _showRestauranteModal(context);
          },
        ),
      ],
    );
  }

  void _showRestauranteModal(BuildContext context, {Restaurante? restauranteExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RestauranteModal(
        restauranteExistente: restauranteExistente,
        onSalvar: (restaurante) async {
          if (restaurante.id != null) {
            await _repositorio.atualizar(restaurante);
          } else {
            await _repositorio.inserir(restaurante);
          }
          if (context.mounted) Navigator.pop(context);
          await _carregarRestaurantes();
        },
      ),
    );
  }
}