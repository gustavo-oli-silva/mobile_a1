import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/refeicao.dart';

class RefeicaoCard extends StatelessWidget {
  final Refeicao refeicao;

  const RefeicaoCard({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(refeicao.nome,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('R\$ ${refeicao.preco.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, color: Colors.redAccent)),
              ],
            ),
            Text(refeicao.restaurante.nome,
                style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
            if (refeicao.descricao != null) ...[
              const SizedBox(height: 6),
              Text(refeicao.descricao!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }
}