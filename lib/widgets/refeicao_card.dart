import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/refeicao.dart';

class RefeicaoCard extends StatelessWidget {
  final Refeicao refeicao;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RefeicaoCard({
    super.key, 
    required this.refeicao,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(refeicao.nome,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
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
                    title: const Text('Excluir refeição?'),
                    content: const Text('Isso também excluirá todas as avaliações desta refeição.'),
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
      ),
    );
  }
}