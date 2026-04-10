import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/widgets/botao.dart';

class RestauranteModal extends StatefulWidget {
  final Function(Restaurante) onSalvar;

  const RestauranteModal({super.key, required this.onSalvar});

  @override
  State<RestauranteModal> createState() => _RestauranteModalState();
}

class _RestauranteModalState extends State<RestauranteModal> {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do restaurante',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descricaoController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Botao(
            texto: 'Salvar',
            onPressed: () {
              if (nomeController.text.isEmpty) return;
              final restaurante = descricaoController.text.isNotEmpty
                  ? Restaurante.comDescricao(nomeController.text, descricaoController.text)
                  : Restaurante(nomeController.text);
              widget.onSalvar(restaurante);
            },
          ),
        ],
      ),
    );
  }
}