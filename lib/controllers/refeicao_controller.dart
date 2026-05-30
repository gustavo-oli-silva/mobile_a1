import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/servicos/pdf_servico.dart';
import 'package:projeto_a1/servicos/refeicao_servico.dart';

/// Controller: orquestra RefeicaoServico → View.
class RefeicaoController extends ChangeNotifier {
  final RefeicaoServico _servico;
  final PdfServico _pdfServico;

  RefeicaoController(this._servico, this._pdfServico);

  List<Refeicao> _lista = [];
  List<Refeicao> _listaFiltrada = [];
  bool _carregando = false;
  String? _erro;
  String _filtroTexto = '';
  Restaurante? _filtroRestaurante;

  List<Refeicao> get listaFiltrada => _listaFiltrada;
  bool get carregando => _carregando;
  String? get erro => _erro;
  String get filtroTexto => _filtroTexto;
  Restaurante? get filtroRestaurante => _filtroRestaurante;

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

  Future<void> salvar(Refeicao refeicao) async {
    await _servico.salvar(refeicao);
    await carregar();
  }

  Future<void> deletar(int id) async {
    await _servico.deletar(id);
    await carregar();
  }

  void aplicarFiltro({String? query, Restaurante? restaurante, bool limpar = false}) {
    if (limpar) {
      _filtroTexto = '';
      _filtroRestaurante = null;
    } else {
      if (query != null) _filtroTexto = query;
      if (restaurante != null || limpar) _filtroRestaurante = restaurante;
    }
    _aplicarFiltroInterno();
  }

  void limparFiltroRestaurante() {
    _filtroRestaurante = null;
    _aplicarFiltroInterno();
  }

  void _aplicarFiltroInterno() {
    _listaFiltrada = _servico.filtrar(
      _lista,
      query: _filtroTexto,
      restaurante: _filtroRestaurante,
    );
    notifyListeners();
  }

  Future<Uint8List> gerarBytesPdf() {
    return _pdfServico.gerarPdf<Refeicao>(
      _listaFiltrada,
      'Relatório de Refeições',
      ['Nome', 'Restaurante', 'Preço', 'Descrição'],
      (r) => [
        r.nome,
        r.restaurante.nome,
        'R\$ ${r.preco.toStringAsFixed(2)}',
        r.descricao ?? '—',
      ],
    );
  }

  Future<String> exportarPdfDesktop() async {
    final bytes = await gerarBytesPdf();
    return _pdfServico.salvarArquivoTemp(bytes, 'refeicoes.pdf');
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}
