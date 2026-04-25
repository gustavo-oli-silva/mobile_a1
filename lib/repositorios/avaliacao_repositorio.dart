import 'package:projeto_a1/banco/database_helper.dart';
import 'package:projeto_a1/modelos/avaliacao.dart';
import 'package:projeto_a1/repositorios/refeicao_repositorio.dart';

class AvaliacaoRepositorio {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final RefeicaoRepositorio _refeicaoRepo = RefeicaoRepositorio();

  Future<int> inserir(Avaliacao avaliacao) async {
    final db = await _dbHelper.database;
    final id = await db.insert('avaliacoes', avaliacao.toMap());
    avaliacao.id = id;
    return id;
  }

  Future<List<Avaliacao>> listar() async {
    final db = await _dbHelper.database;
    final maps = await db.query('avaliacoes', orderBy: 'id DESC');

    final List<Avaliacao> avaliacoes = [];
    for (final m in maps) {
      final refeicaoId = m['refeicao_id'] as int;
      final refeicao = await _refeicaoRepo.buscarPorId(refeicaoId);
      if (refeicao != null) {
        avaliacoes.add(Avaliacao.fromMap(m, refeicao));
      }
    }
    return avaliacoes;
  }

  Future<int> deletar(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('avaliacoes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> atualizar(Avaliacao avaliacao) async {
    final db = await _dbHelper.database;
    return await db.update(
      'avaliacoes',
      avaliacao.toMap(),
      where: 'id = ?',
      whereArgs: [avaliacao.id],
    );
  }
}
