import 'package:projeto_a1/modelos/restaurante.dart';
import 'package:projeto_a1/repositorios/restaurante_repositorio.dart';

/// Serviço: valida regras de negócio e orquestra o repositório.
class RestauranteServico {
  final RestauranteRepositorio _repositorio;

  RestauranteServico(this._repositorio);

  Future<List<Restaurante>> listar() => _repositorio.listar();

  /// Valida e persiste (insert ou update).
  Future<void> salvar(Restaurante restaurante) {
    if (restaurante.nome.trim().isEmpty) {
      throw ArgumentError('O nome do restaurante não pode ser vazio.');
    }
    if (restaurante.id != null) {
      return _repositorio.atualizar(restaurante);
    }
    return _repositorio.inserir(restaurante).then((_) {});
  }

  Future<void> deletar(int id) => _repositorio.deletar(id);

  /// Filtragem em memória por texto no nome ou descrição.
  List<Restaurante> filtrar(List<Restaurante> lista, String query) {
    if (query.trim().isEmpty) return lista;
    final q = query.toLowerCase();
    return lista.where((r) {
      return r.nome.toLowerCase().contains(q) ||
          (r.descricao?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
