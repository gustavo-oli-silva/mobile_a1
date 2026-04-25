import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_michelin.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE restaurantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE refeicoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        preco REAL NOT NULL,
        restaurante_id INTEGER NOT NULL,
        FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE avaliacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nota_apresentacao REAL NOT NULL,
        nota_porcao REAL NOT NULL,
        nota_temperatura REAL NOT NULL,
        anotacao TEXT NOT NULL,
        refeicao_id INTEGER NOT NULL,
        FOREIGN KEY (refeicao_id) REFERENCES refeicoes(id) ON DELETE CASCADE
      )
    ''');
  }
}
