import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/servicos/avaliacao_servico.dart';
import 'package:projeto_a1/servicos/pdf_servico.dart';

/// Controller: orquestra AvaliacaoServico → View.
class AvaliacaoController extends ChangeNotifier {
  final AvaliacaoServico _servico;
  final PdfServico _pdfServico;

  AvaliacaoController(this._servico, this._pdfServico);

  List<Avaliacao> _lista = [];
  List<Avaliacao> _listaFiltrada = [];
  bool _carregando = false;
  String? _erro;
  String _filtroTexto = '';
  double _filtroNotaMinima = 0;

  List<Avaliacao> get listaFiltrada => _listaFiltrada;
  bool get carregando => _carregando;
  String? get erro => _erro;
  String get filtroTexto => _filtroTexto;
  double get filtroNotaMinima => _filtroNotaMinima;

  Future<void> carregar() async {
    _setCarregando(true);
    try {
      _lista = await _servico.listar();
      _aplicarFiltroInterno();
      _erro = null;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> salvar(Avaliacao avaliacao) async {
    await _servico.salvar(avaliacao);
    await carregar();
  }

  Future<void> deletar(int id) async {
    await _servico.deletar(id);
    await carregar();
  }

  void aplicarFiltro({String? query, double? notaMinima}) {
    if (query != null) _filtroTexto = query;
    if (notaMinima != null) _filtroNotaMinima = notaMinima;
    _aplicarFiltroInterno();
  }

  void _aplicarFiltroInterno() {
    _listaFiltrada = _servico.filtrar(
      _lista,
      query: _filtroTexto,
      notaMinima: _filtroNotaMinima,
    );
    notifyListeners();
  }

  Future<Uint8List> gerarBytesPdf() {
    final pratosUnicos = _listaFiltrada.map((a) => a.prato.id).toSet().length;
    final restaurantesUnicos =
        _listaFiltrada.map((a) => a.prato.restaurante.id).toSet().length;

    return _pdfServico.gerarPdf<Avaliacao>(
      _listaFiltrada,
      'Relatório de Avaliações',
      ['Prato', 'Restaurante', 'Apresent.', 'Porção', 'Temp.', 'Média', 'Anotação'],
      (a) => [
        a.prato.nome,
        a.prato.restaurante.nome,
        a.notaApresentacao.toStringAsFixed(1),
        a.notaPorcao.toStringAsFixed(1),
        a.notaTemperatura.toStringAsFixed(1),
        a.notaMedia.toStringAsFixed(1),
        a.anotacao,
      ],
      resumo: {
        'Total de avaliações': '${_listaFiltrada.length}',
        'Pratos avaliados': '$pratosUnicos',
        'Restaurantes avaliados': '$restaurantesUnicos',
      },
    );
  }

  Future<String> exportarPdfDesktop() async {
    final bytes = await gerarBytesPdf();
    return _pdfServico.salvarArquivoTemp(bytes, 'avaliacoes.pdf');
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}
