import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/widgets/botao.dart';
import 'package:projeto_a1/widgets/restaurante_card.dart';
import 'package:projeto_a1/widgets/restaurante_modal.dart';

class RestauranteTela extends StatefulWidget {
  const RestauranteTela({super.key});

  @override
  State<RestauranteTela> createState() => _RestauranteTelaState();
}

class _RestauranteTelaState extends State<RestauranteTela> {
  List<Restaurante> restaurantes = [
    Restaurante.comDescricao('Fazendinha', 'massa')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: restaurantes.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () { _showRestauranteModal(context); },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ) : null,
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
        SizedBox(height: 24),
        Expanded(child: ListView.builder(
          itemCount: restaurantes.length,
          itemBuilder: (context, index) {
            final restaurante = restaurantes[index];

            return RestauranteCard(restaurante: restaurante);
        }))
      ],
    );
  }

  Widget _ifEmpty(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Nenhum restaurante encontrado...',
          style: TextStyle(fontSize: 40),
          textAlign: TextAlign.center),
          Botao(texto: 'Registre um agora mesmo!', onPressed: () { })
        ],
      );
  }

  void _showRestauranteModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => RestauranteModal(
      onSalvar: (restaurante) {
        setState(() => restaurantes.add(restaurante));
        Navigator.pop(context);
        },
      ), 
    );
  }
}