import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

class RestauranteCard extends StatelessWidget {
  final Restaurante restaurante;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RestauranteCard({
    super.key, 
    required this.restaurante,
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
                  Text(restaurante.nome,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  if (restaurante.descricao != null) ...[
                    const SizedBox(height: 4),
                    Text(restaurante.descricao!,
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
                    title: const Text('Excluir restaurante?'),
                    content: const Text('Isso também excluirá todas as refeições e avaliações deste restaurante.'),
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