import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

class RestauranteCard extends StatelessWidget {
  final Restaurante restaurante;

  const RestauranteCard({super.key, required this.restaurante});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    );
  }
}