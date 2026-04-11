import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/widgets/avaliacao_card.dart';
import 'package:projeto_a1/widgets/avaliacao_modal.dart';
import 'package:projeto_a1/widgets/botao.dart';

class AvaliacoesTela extends StatefulWidget {
  AvaliacoesTela({super.key});

  @override
  State<AvaliacoesTela> createState() => _AvaliacoesTelaState();
}

class _AvaliacoesTelaState extends State<AvaliacoesTela> {
  List<Avaliacao> avaliacoes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: avaliacoes.isNotEmpty 
    ? FloatingActionButton.extended(
        onPressed: () { 
          _showAvaliacaoModal(context); 
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Avalie',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ) 
    : null,
      body: SizedBox(
        width: double.infinity,
        child: avaliacoes.isNotEmpty ? _content() : _ifEmpty(context)
      ),
    );
  }

  Widget _content() {
    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Expanded(child: 
            ListView.builder(
              itemCount: avaliacoes.length,
              itemBuilder: (context, index) {
                final avaliacao = avaliacoes[index];

                return AvaliacaoCard(avaliacao: avaliacao);
            })
            ),
          ],
        );
  }

  void _showAvaliacaoModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AvaliacaoModal(
      refeicoes: [Refeicao('Macarronada', 67.67, Restaurante('Aura'))],
      onSalvar: (avaliacao) {
        setState(() => avaliacoes.add(avaliacao));
        Navigator.pop(context);
      },
    ),
  );
}

  Widget _ifEmpty(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Ainda nao fez uma avaliaçao?',
          style: TextStyle(fontSize: 40),
          textAlign: TextAlign.center),
          Botao(texto: 'Faça uma avaliacao agora', onPressed: () { _showAvaliacaoModal(context); })
        ],
      );
  }
}