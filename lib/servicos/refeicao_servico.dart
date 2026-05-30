import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/repositorios/refeicao_repositorio.dart';

/// Serviço: valida regras de negócio e orquestra o repositório.
class RefeicaoServico {
  final RefeicaoRepositorio _repositorio;

  RefeicaoServico(this._repositorio);

  Future<List<Refeicao>> listar() => _repositorio.listar();

  Future<void> salvar(Refeicao refeicao) {
    if (refeicao.nome.trim().isEmpty) {
      throw ArgumentError('O nome da refeição não pode ser vazio.');
    }
    if (refeicao.preco < 0) {
      throw ArgumentError('O preço não pode ser negativo.');
    }
    if (refeicao.id != null) {
      return _repositorio.atualizar(refeicao);
    }
    return _repositorio.inserir(refeicao).then((_) {});
  }

  Future<void> deletar(int id) => _repositorio.deletar(id);

  /// Filtragem em memória por texto no nome e/ou por restaurante.
  List<Refeicao> filtrar(
    List<Refeicao> lista, {
    String query = '',
    Restaurante? restaurante,
  }) {
    var resultado = lista;
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      resultado = resultado
          .where((r) =>
              r.nome.toLowerCase().contains(q) ||
              (r.descricao?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    if (restaurante != null) {
      resultado = resultado
          .where((r) => r.restaurante.id == restaurante.id)
          .toList();
    }
    return resultado;
  }
}
