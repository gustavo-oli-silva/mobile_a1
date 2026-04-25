import 'package:projeto_a1/banco/database_helper.dart';
import 'package:projeto_a1/modelos/refeicao.dart';
import 'package:projeto_a1/repositorios/restaurante_repositorio.dart';

class RefeicaoRepositorio {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final RestauranteRepositorio _restauranteRepo = RestauranteRepositorio();

  Future<int> inserir(Refeicao refeicao) async {
    final db = await _dbHelper.database;
    final id = await db.insert('refeicoes', refeicao.toMap());
    refeicao.id = id;
    return id;
  }

  Future<List<Refeicao>> listar() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT r.*, res.id AS res_id, res.nome AS res_nome, res.descricao AS res_descricao
      FROM refeicoes r
      INNER JOIN restaurantes res ON r.restaurante_id = res.id
      ORDER BY r.nome ASC
    ''');

    return maps.map((m) {
      final restauranteMap = {
        'id': m['res_id'],
        'nome': m['res_nome'],
        'descricao': m['res_descricao'],
      };
      final restaurante = RestauranteRepositorio().fromMap(restauranteMap);
      return Refeicao.fromMap(m, restaurante);
    }).toList();
  }

  Future<Refeicao?> buscarPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT r.*, res.id AS res_id, res.nome AS res_nome, res.descricao AS res_descricao
      FROM refeicoes r
      INNER JOIN restaurantes res ON r.restaurante_id = res.id
      WHERE r.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    final m = maps.first;
    final restauranteMap = {
      'id': m['res_id'],
      'nome': m['res_nome'],
      'descricao': m['res_descricao'],
    };
    final restaurante = RestauranteRepositorio().fromMap(restauranteMap);
    return Refeicao.fromMap(m, restaurante);
  }

  Future<int> deletar(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('refeicoes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> atualizar(Refeicao refeicao) async {
    final db = await _dbHelper.database;
    return await db.update(
      'refeicoes',
      refeicao.toMap(),
      where: 'id = ?',
      whereArgs: [refeicao.id],
    );
  }
}
