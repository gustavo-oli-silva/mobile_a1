import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/repositorios/avaliacao_repositorio.dart';
import 'package:projeto_a1/repositorios/refeicao_repositorio.dart';
import 'package:projeto_a1/widgets/avaliacao_card.dart';
import 'package:projeto_a1/widgets/avaliacao_modal.dart';
import 'package:projeto_a1/widgets/botao.dart';

class AvaliacoesTela extends StatefulWidget {
  const AvaliacoesTela({super.key});

  @override
  State<AvaliacoesTela> createState() => _AvaliacoesTelaState();
}

class _AvaliacoesTelaState extends State<AvaliacoesTela> {
  final AvaliacaoRepositorio _repositorio = AvaliacaoRepositorio();
  final RefeicaoRepositorio _refeicaoRepositorio = RefeicaoRepositorio();
  List<Avaliacao> avaliacoes = [];
  List<Refeicao> refeicoes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final avaliacoesList = await _repositorio.listar();
    final refeicoesList = await _refeicaoRepositorio.listar();
    setState(() {
      avaliacoes = avaliacoesList;
      refeicoes = refeicoesList;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        child: avaliacoes.isNotEmpty ? _content() : _ifEmpty(context),
      ),
    );
  }

  Widget _content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: avaliacoes.length,
            itemBuilder: (context, index) {
              final avaliacao = avaliacoes[index];
              return AvaliacaoCard(
                avaliacao: avaliacao,
                onEdit: () => _showAvaliacaoModal(context, avaliacaoExistente: avaliacao),
                onDelete: () async {
                  if (avaliacao.id != null) {
                    await _repositorio.deletar(avaliacao.id!);
                    await _carregarDados();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAvaliacaoModal(BuildContext context, {Avaliacao? avaliacaoExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AvaliacaoModal(
        refeicoes: refeicoes,
        avaliacaoExistente: avaliacaoExistente,
        onSalvar: (avaliacao) async {
          if (avaliacao.id != null) {
            await _repositorio.atualizar(avaliacao);
          } else {
            await _repositorio.inserir(avaliacao);
          }
          if (context.mounted) Navigator.pop(context);
          await _carregarDados();
        },
      ),
    );
  }

  Widget _ifEmpty(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Ainda não fez uma avaliação?',
          style: TextStyle(fontSize: 40),
          textAlign: TextAlign.center,
        ),
        Botao(
          texto: 'Faça uma avaliação agora',
          onPressed: () {
            _showAvaliacaoModal(context);
          },
        ),
      ],
    );
  }
}