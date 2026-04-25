import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/repositorios/refeicao_repositorio.dart';
import 'package:projeto_a1/repositorios/restaurante_repositorio.dart';
import 'package:projeto_a1/widgets/botao.dart';
import 'package:projeto_a1/widgets/refeicao_card.dart';
import 'package:projeto_a1/widgets/refeicao_modal.dart';

class RefeicoesTela extends StatefulWidget {
  const RefeicoesTela({super.key});

  @override
  State<RefeicoesTela> createState() => _RefeicoesTelaState();
}

class _RefeicoesTelaState extends State<RefeicoesTela> {
  final RefeicaoRepositorio _repositorio = RefeicaoRepositorio();
  final RestauranteRepositorio _restauranteRepositorio = RestauranteRepositorio();
  List<Refeicao> refeicoes = [];
  List<Restaurante> restaurantes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final refeicoesList = await _repositorio.listar();
    final restaurantesList = await _restauranteRepositorio.listar();
    setState(() {
      refeicoes = refeicoesList;
      restaurantes = restaurantesList;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        child: refeicoes.isNotEmpty ? _content() : _ifEmpty(context),
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
            itemCount: refeicoes.length,
            itemBuilder: (context, index) {
              final refeicao = refeicoes[index];
              return RefeicaoCard(
                refeicao: refeicao,
                onEdit: () => _showRefeicoesModal(context, refeicaoExistente: refeicao),
                onDelete: () async {
                  if (refeicao.id != null) {
                    await _repositorio.deletar(refeicao.id!);
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

  void _showRefeicoesModal(BuildContext context, {Refeicao? refeicaoExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RefeicaoModal(
        restaurantes: restaurantes,
        refeicaoExistente: refeicaoExistente,
        onSalvar: (refeicao) async {
          if (refeicao.id != null) {
            await _repositorio.atualizar(refeicao);
          } else {
            await _repositorio.inserir(refeicao);
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
          'Nenhuma refeição encontrada...',
          style: TextStyle(fontSize: 40),
          textAlign: TextAlign.center,
        ),
        Botao(
          texto: 'Registre uma agora mesmo!',
          onPressed: () {
            _showRefeicoesModal(context);
          },
        ),
      ],
    );
  }
}
