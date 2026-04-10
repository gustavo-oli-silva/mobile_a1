import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/widgets/botao.dart';

class AvaliacaoModal extends StatefulWidget {
  final List<Refeicao> refeicoes;
  final Function(Avaliacao) onSalvar;

  const AvaliacaoModal({super.key, required this.refeicoes, required this.onSalvar});

  @override
  State<AvaliacaoModal> createState() => _AvaliacaoModalState();
}

class _AvaliacaoModalState extends State<AvaliacaoModal> {
  Refeicao? pratoSelecionado;
  double notaApresentacao = 3;
  double notaPorcao = 3;
  double notaTemperatura = 3;
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
          DropdownButtonFormField<Refeicao>(
            hint: const Text('Selecione o prato'),
            initialValue: pratoSelecionado,
            items: widget.refeicoes.map((r) => DropdownMenuItem(
              value: r,
              child: Text(r.nome),
            )).toList(),
            onChanged: (r) => setState(() => pratoSelecionado = r),
          ),
          const SizedBox(height: 12),
          Text('Apresentação: ${notaApresentacao.round()}'),
          Slider(
            value: notaApresentacao, min: 1, max: 5, divisions: 4,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => notaApresentacao = v),
          ),
          Text('Porção: ${notaPorcao.round()}'),
          Slider(
            value: notaPorcao, min: 1, max: 5, divisions: 4,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => notaPorcao = v),
          ),
          Text('Temperatura: ${notaTemperatura.round()}'),
          Slider(
            value: notaTemperatura, min: 1, max: 5, divisions: 4,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => notaTemperatura = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descricaoController,
            decoration: const InputDecoration(
              labelText: 'Anotação',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Botao(
            texto: 'Salvar',
            onPressed: () {
              if (pratoSelecionado == null) return;
              widget.onSalvar(Avaliacao(
                pratoSelecionado!,
                notaApresentacao,
                notaPorcao,
                notaTemperatura,
                descricaoController.text,
              ));
            },
          ),
        ],
      ),
    );
  }
}