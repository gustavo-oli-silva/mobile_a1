import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';

class AvaliacaoCard extends StatelessWidget {
  final Avaliacao avaliacao;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AvaliacaoCard({
    super.key, 
    required this.avaliacao,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _linha(String label, double nota) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Row(
          children: List.generate(5, (i) => Icon(
            i < nota.round() ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.redAccent,
          )),
        ),
      ],
    );
  }

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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(avaliacao.prato.nome,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(avaliacao.prato.restaurante.nome,
                          style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
                      Text('R\$ ${avaliacao.prato.preco.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Excluir avaliação?'),
                        content: const Text('Tem certeza de que deseja excluir esta avaliação?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete();
                            }, 
                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _linha('Apresentação', avaliacao.notaApresentacao),
            const SizedBox(height: 4),
            _linha('Porção', avaliacao.notaPorcao),
            const SizedBox(height: 4),
            _linha('Temperatura', avaliacao.notaTemperatura),
            const SizedBox(height: 4),
            _linha('Nota geral', (avaliacao.notaApresentacao + avaliacao.notaPorcao + avaliacao.notaTemperatura) / 3),
            if (avaliacao.anotacao.isNotEmpty) ...[
              const Divider(height: 20),
              Text('"${avaliacao.anotacao}"',
                  style: const TextStyle(fontSize: 13, color: Colors.black)),
            ]
          ],
        ),
      ),
    );
  }
}