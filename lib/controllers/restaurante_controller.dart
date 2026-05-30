import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/servicos/pdf_servico.dart';
import 'package:projeto_a1/servicos/restaurante_servico.dart';

/// Controller: orquestra RestauranteServico → View.
/// Expõe estado (lista, loading, erro, filtro) via ChangeNotifier.
class RestauranteController extends ChangeNotifier {
  final RestauranteServico _servico;
  final PdfServico _pdfServico;

  RestauranteController(this._servico, this._pdfServico);

  List<Restaurante> _lista = [];
  List<Restaurante> _listaFiltrada = [];
  bool _carregando = false;
  String? _erro;
  String _filtroTexto = '';

  List<Restaurante> get listaFiltrada => _listaFiltrada;
  bool get carregando => _carregando;
  String? get erro => _erro;
  String get filtroTexto => _filtroTexto;

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

  Future<void> salvar(Restaurante restaurante) async {
    await _servico.salvar(restaurante);
    await carregar();
  }

  Future<void> deletar(int id) async {
    await _servico.deletar(id);
    await carregar();
  }

  void aplicarFiltro(String query) {
    _filtroTexto = query;
    _aplicarFiltroInterno();
  }

  void _aplicarFiltroInterno() {
    _listaFiltrada = _servico.filtrar(_lista, _filtroTexto);
    notifyListeners();
  }

  /// Gera o PDF dos dados filtrados e retorna os bytes para a View entregar.
  Future<Uint8List> gerarBytesPdf() {
    return _pdfServico.gerarPdf<Restaurante>(
      _listaFiltrada,
      'Relatório de Restaurantes',
      ['Nome', 'Descrição'],
      (r) => [r.nome, r.descricao ?? '—'],
    );
  }

  Future<String> exportarPdfDesktop() async {
    final bytes = await gerarBytesPdf();
    return _pdfServico.salvarArquivoTemp(bytes, 'restaurantes.pdf');
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}
