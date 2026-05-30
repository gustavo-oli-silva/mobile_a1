import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_a1/controllers/restaurante_controller.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/widgets/botao.dart';
import 'package:projeto_a1/widgets/restaurante_card.dart';
import 'package:projeto_a1/widgets/restaurante_modal.dart';

/// View: apenas UI. Lê estado do RestauranteController via Provider.
/// Desconhece repositórios e serviços.
class RestauranteTela extends StatefulWidget {
  const RestauranteTela({super.key});

  @override
  State<RestauranteTela> createState() => _RestauranteTelaState();
}

class _RestauranteTelaState extends State<RestauranteTela> {
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carrega dados ao montar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Consumer<RestauranteController>(
      builder: (context, controller, _) {
        if (controller.carregando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.erro != null) {
          return Center(child: Text('Erro: ${controller.erro}'));
        }

        final lista = controller.listaFiltrada;

        return Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lista.isNotEmpty) ...[
                FloatingActionButton(
                  heroTag: 'pdf_restaurante',
                  mini: true,
                  backgroundColor: Colors.red.shade800,
                  tooltip: 'Exportar PDF',
                  onPressed: () => _exportarPdf(controller),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
                const SizedBox(height: 8),
              ],
              FloatingActionButton.extended(
                heroTag: 'add_restaurante',
                onPressed: () => _showModal(context, controller),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Adicionar',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de busca (Etapa 2 – filtros)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar restaurante...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _buscaController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _buscaController.clear();
                              controller.aplicarFiltro('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (q) {
                    setState(() {}); // para atualizar o ícone de limpar
                    controller.aplicarFiltro(q);
                  },
                ),
              ),
              Expanded(
                child: lista.isNotEmpty
                    ? ListView.builder(
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final restaurante = lista[index];
                          return RestauranteCard(
                            restaurante: restaurante,
                            onEdit: () =>
                                _showModal(context, controller, restauranteExistente: restaurante),
                            onDelete: () async {
                              if (restaurante.id != null) {
                                await controller.deletar(restaurante.id!);
                              }
                            },
                          );
                        },
                      )
                    : _ifEmpty(context, controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ifEmpty(BuildContext context, RestauranteController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Nenhum restaurante encontrado...',
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        Botao(
          texto: 'Registre um agora mesmo!',
          onPressed: () => _showModal(context, controller),
        ),
      ],
    );
  }

  void _showModal(BuildContext context, RestauranteController controller,
      {Restaurante? restauranteExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RestauranteModal(
        restauranteExistente: restauranteExistente,
        onSalvar: (restaurante) async {
          await controller.salvar(restaurante);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _exportarPdf(RestauranteController controller) async {
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
        final file = File('${dir.path}/restaurantes.pdf');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Relatório de Restaurantes');
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