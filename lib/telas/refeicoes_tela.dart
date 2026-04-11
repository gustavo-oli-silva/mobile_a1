import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/widgets/botao.dart';
import 'package:projeto_a1/widgets/refeicao_card.dart';
import 'package:projeto_a1/widgets/refeicao_modal.dart';

class RefeicoesTela extends StatefulWidget {
  const RefeicoesTela({super.key});

  @override
  State<RefeicoesTela> createState() => _RefeicoesTelaState();
}

class _RefeicoesTelaState extends State<RefeicoesTela> {
  List<Refeicao> refeicoes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: refeicoes.isNotEmpty 
    ? FloatingActionButton.extended(
        onPressed: () { 
          _showRefeicoesModal(context); 
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
        child: refeicoes.isNotEmpty ? _content() : _ifEmpty(context)
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
          itemCount: refeicoes.length,
          itemBuilder: (context, index) {
            final refeicao = refeicoes[index];

            return RefeicaoCard(refeicao: refeicao);
        }))
      ],
    );
  }

  void _showRefeicoesModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => RefeicaoModal(
      restaurantes: [Restaurante('Aura')],
      onSalvar: (refeicao) {
        setState(() => refeicoes.add(refeicao));
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
          Text('Nenhuma refeiçao encontrada...',
          style: TextStyle(fontSize: 40),
          textAlign: TextAlign.center),
          Botao(texto: 'Registre uma agora mesmo!', onPressed: () { _showRefeicoesModal(context); })
        ],
      );
  }
}
