import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/repositorios/avaliacao_repositorio.dart';

/// Serviço: valida regras de negócio e orquestra o repositório.
class AvaliacaoServico {
  final AvaliacaoRepositorio _repositorio;

  AvaliacaoServico(this._repositorio);

  Future<List<Avaliacao>> listar() => _repositorio.listar();

  Future<void> salvar(Avaliacao avaliacao) {
    if (avaliacao.id != null) {
      return _repositorio.atualizar(avaliacao);
    }
    return _repositorio.inserir(avaliacao).then((_) {});
  }

  Future<void> deletar(int id) => _repositorio.deletar(id);

  /// Filtragem em memória por nome do prato e/ou nota média mínima.
  List<Avaliacao> filtrar(
    List<Avaliacao> lista, {
    String query = '',
    double notaMinima = 0,
  }) {
    var resultado = lista;
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      resultado = resultado
          .where((a) =>
              a.prato.nome.toLowerCase().contains(q) ||
              a.prato.restaurante.nome.toLowerCase().contains(q))
          .toList();
    }
    if (notaMinima > 0) {
      resultado =
          resultado.where((a) => a.notaMedia >= notaMinima).toList();
    }
    return resultado;
  }
}
