import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_a1/controllers/avaliacao_controller.dart';
import 'package:projeto_a1/controllers/refeicao_controller.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/widgets/avaliacao_card.dart';
import 'package:projeto_a1/widgets/avaliacao_modal.dart';
import 'package:projeto_a1/widgets/botao.dart';

/// View: apenas UI. Lê estado do AvaliacaoController e RefeicaoController
/// via Provider. Sem acesso a repositórios ou serviços.
class AvaliacoesTela extends StatefulWidget {
  const AvaliacoesTela({super.key});

  @override
  State<AvaliacoesTela> createState() => _AvaliacoesTelaState();
}

class _AvaliacoesTelaState extends State<AvaliacoesTela> {
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvaliacaoController>().carregar();
      context.read<RefeicaoController>().carregar();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AvaliacaoController, RefeicaoController>(
      builder: (context, controller, refeicaoCtrl, _) {
        if (controller.carregando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.erro != null) {
          return Center(child: Text('Erro: ${controller.erro}'));
        }

        final lista = controller.listaFiltrada;
        final refeicoes = refeicaoCtrl.listaFiltrada;

        return Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lista.isNotEmpty) ...[
                FloatingActionButton(
                  heroTag: 'pdf_avaliacao',
                  mini: true,
                  backgroundColor: Colors.red.shade800,
                  tooltip: 'Exportar PDF',
                  onPressed: () => _exportarPdf(controller),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
                const SizedBox(height: 8),
              ],
              FloatingActionButton.extended(
                heroTag: 'add_avaliacao',
                onPressed: () => _showModal(context, controller, refeicoes),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Avalie',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            ],
          ),
          body: Column(
            children: [
              // Filtro por texto (nome do prato ou restaurante)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por prato ou restaurante...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _buscaController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _buscaController.clear();
                              controller.aplicarFiltro(query: '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (q) {
                    setState(() {});
                    controller.aplicarFiltro(query: q);
                  },
                ),
              ),
              // Filtro por nota mínima
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Nota mínima:'),
                    const SizedBox(width: 8),
                    Text(
                      controller.filtroNotaMinima == 0
                          ? 'Todas'
                          : controller.filtroNotaMinima.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    Expanded(
                      child: Slider(
                        value: controller.filtroNotaMinima,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        activeColor: Colors.redAccent,
                        onChanged: (v) {
                          controller.aplicarFiltro(notaMinima: v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: lista.isNotEmpty
                    ? ListView.builder(
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final avaliacao = lista[index];
                          return AvaliacaoCard(
                            avaliacao: avaliacao,
                            onEdit: () => _showModal(
                              context, controller, refeicoes,
                              avaliacaoExistente: avaliacao,
                            ),
                            onDelete: () async {
                              if (avaliacao.id != null) {
                                await controller.deletar(avaliacao.id!);
                              }
                            },
                          );
                        },
                      )
                    : _ifEmpty(context, controller, refeicoes),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ifEmpty(BuildContext context, AvaliacaoController controller,
      List<Refeicao> refeicoes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Ainda não fez uma avaliação?',
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        Botao(
          texto: 'Faça uma avaliação agora',
          onPressed: () => _showModal(context, controller, refeicoes),
        ),
      ],
    );
  }

  void _showModal(BuildContext context, AvaliacaoController controller,
      List<Refeicao> refeicoes,
      {Avaliacao? avaliacaoExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AvaliacaoModal(
        refeicoes: refeicoes,
        avaliacaoExistente: avaliacaoExistente,
        onSalvar: (avaliacao) async {
          await controller.salvar(avaliacao);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _exportarPdf(AvaliacaoController controller) async {
    try {
      if (controller.listaFiltrada.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum dado para exportar.')),
        );
        return;
      }
      final bytes = await controller.gerarBytesPdf();

      if (!kIsWeb &&
          (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        final path = await controller.exportarPdfDesktop();
        await OpenFile.open(path);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/avaliacoes.pdf');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Relatório de Avaliações');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }
  }
}