import 'package:projeto_a1/banco/database_helper.dart';
import 'package:projeto_a1/modelos/restaurante.dart';

class RestauranteRepositorio {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> inserir(Restaurante restaurante) async {
    final db = await _dbHelper.database;
    final id = await db.insert('restaurantes', restaurante.toMap());
    restaurante.id = id;
    return id;
  }

  Restaurante fromMap(Map<String, dynamic> map) => Restaurante.fromMap(map);

  Future<List<Restaurante>> listar() async {
    final db = await _dbHelper.database;
    final maps = await db.query('restaurantes', orderBy: 'nome ASC');
    return maps.map((m) => Restaurante.fromMap(m)).toList();
  }

  Future<Restaurante?> buscarPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'restaurantes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Restaurante.fromMap(maps.first);
  }

  Future<int> deletar(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('restaurantes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> atualizar(Restaurante restaurante) async {
    final db = await _dbHelper.database;
    return await db.update(
      'restaurantes',
      restaurante.toMap(),
      where: 'id = ?',
      whereArgs: [restaurante.id],
    );
  }
}
