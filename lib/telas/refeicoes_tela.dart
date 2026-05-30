import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_a1/controllers/refeicao_controller.dart';
import 'package:projeto_a1/controllers/restaurante_controller.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/widgets/botao.dart';
import 'package:projeto_a1/widgets/refeicao_card.dart';
import 'package:projeto_a1/widgets/refeicao_modal.dart';

/// View: apenas UI. Lê estado do RefeicaoController (e RestauranteController
/// para popular o filtro de restaurante) via Provider.
class RefeicoesTela extends StatefulWidget {
  const RefeicoesTela({super.key});

  @override
  State<RefeicoesTela> createState() => _RefeicoesTelaState();
}

class _RefeicoesTelaState extends State<RefeicoesTela> {
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RefeicaoController>().carregar();
      context.read<RestauranteController>().carregar();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RefeicaoController, RestauranteController>(
      builder: (context, controller, restauranteCtrl, _) {
        if (controller.carregando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.erro != null) {
          return Center(child: Text('Erro: ${controller.erro}'));
        }

        final lista = controller.listaFiltrada;
        final restaurantes = restauranteCtrl.listaFiltrada;

        return Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lista.isNotEmpty) ...[
                FloatingActionButton(
                  heroTag: 'pdf_refeicao',
                  mini: true,
                  backgroundColor: Colors.red.shade800,
                  tooltip: 'Exportar PDF',
                  onPressed: () => _exportarPdf(controller),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
                const SizedBox(height: 8),
              ],
              FloatingActionButton.extended(
                heroTag: 'add_refeicao',
                onPressed: () =>
                    _showModal(context, controller, restaurantes),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Adicionar',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            ],
          ),
          body: Column(
            children: [
              // Filtro por texto
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar refeição...',
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
              // Filtro por restaurante
              if (restaurantes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<Restaurante?>(
                    decoration: InputDecoration(
                      labelText: 'Filtrar por restaurante',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: controller.filtroRestaurante,
                    items: [
                      const DropdownMenuItem<Restaurante?>(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...restaurantes.map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.nome),
                          )),
                    ],
                    onChanged: (r) {
                      if (r == null) {
                        controller.limparFiltroRestaurante();
                      } else {
                        controller.aplicarFiltro(restaurante: r);
                      }
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: lista.isNotEmpty
                    ? ListView.builder(
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final refeicao = lista[index];
                          return RefeicaoCard(
                            refeicao: refeicao,
                            onEdit: () => _showModal(
                              context, controller, restaurantes,
                              refeicaoExistente: refeicao,
                            ),
                            onDelete: () async {
                              if (refeicao.id != null) {
                                await controller.deletar(refeicao.id!);
                              }
                            },
                          );
                        },
                      )
                    : _ifEmpty(context, controller, restaurantes),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ifEmpty(BuildContext context, RefeicaoController controller,
      List<Restaurante> restaurantes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Nenhuma refeição encontrada...',
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        Botao(
          texto: 'Registre uma agora mesmo!',
          onPressed: () => _showModal(context, controller, restaurantes),
        ),
      ],
    );
  }

  void _showModal(BuildContext context, RefeicaoController controller,
      List<Restaurante> restaurantes,
      {Refeicao? refeicaoExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RefeicaoModal(
        restaurantes: restaurantes,
        refeicaoExistente: refeicaoExistente,
        onSalvar: (refeicao) async {
          await controller.salvar(refeicao);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _exportarPdf(RefeicaoController controller) async {
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
        final file = File('${dir.path}/refeicoes.pdf');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Relatório de Refeições');
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
