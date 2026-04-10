import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/widgets/botao.dart';

class RefeicaoModal extends StatefulWidget {
  final List<Restaurante> restaurantes;
  final Function(Refeicao) onSalvar;

  const RefeicaoModal({super.key, required this.restaurantes, required this.onSalvar});

  @override
  State<RefeicaoModal> createState() => _RefeicaoModalState();
}

class _RefeicaoModalState extends State<RefeicaoModal> {
  Restaurante? restauranteSelecionado;
  final nomeController = TextEditingController();
  final precoController = TextEditingController();
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
          DropdownButtonFormField<Restaurante>(
            hint: const Text('Selecione o restaurante'),
            initialValue: restauranteSelecionado,
            items: widget.restaurantes.map((r) => DropdownMenuItem(
              value: r,
              child: Text(r.nome),
            )).toList(),
            onChanged: (r) => setState(() => restauranteSelecionado = r),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do prato',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: precoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Preço',
              prefixText: 'R\$ ',
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
              if (restauranteSelecionado == null) return;
              if (nomeController.text.isEmpty) return;
              final preco = double.tryParse(precoController.text) ?? 0.0;
              final refeicao = descricaoController.text.isNotEmpty
                  ? Refeicao.comDescricao(nomeController.text, descricaoController.text, preco, restauranteSelecionado!)
                  : Refeicao(nomeController.text, preco, restauranteSelecionado!);
              widget.onSalvar(refeicao);
            },
          ),
        ],
      ),
    );
  }
}